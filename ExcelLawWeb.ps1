
Param(
     [Parameter(Mandatory = $true, valueFromPipeline=$true, HelpMessage="Tisane API key: ")][String] $APIkey, # from https://dev.tisane.ai/developer
     [Parameter(Mandatory = $true, valueFromPipeline=$true, HelpMessage="Language code: ")][String] $languageCode, # assuming the spreadsheet is monolingual
     [Parameter(Mandatory = $true, valueFromPipeline=$true, HelpMessage="Spreadsheet path: ")][String] $path, # for both the input and the output
     [Parameter(Mandatory = $true, valueFromPipeline=$true, HelpMessage="Spreadsheet local name: ")][String] $filename # input spreadsheet
)


if (-not($path -like '*\')) {
   $path = $path + "\"
}
$SPREADSHEET_PATHNAME = "$path$filename"
$outFilename = $path + 'out_' + $filename
$ROW_COUNT_IN_SPREADSHEET = 1000

## overcome the HTTPS error: https://stackoverflow.com/questions/11696944/powershell-v3-invoke-webrequest-https-error
If (-not ("TrustAllCertsPolicy" -as [type])) {
  Add-Type @"
      using System.Net;
      using System.Security.Cryptography.X509Certificates;
      public class TrustAllCertsPolicy : ICertificatePolicy {
          public bool CheckValidationResult(
              ServicePoint srvPoint, X509Certificate certificate,
              WebRequest request, int certificateProblem) {
              return true;
          }
      }
"@
}
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$header = @{}
$header.Add('Ocp-Apim-Subscription-Key', "$APIkey")


$Excel = New-Object -ComObject Excel.Application
$Workbook = $Excel.Workbooks.Open($SPREADSHEET_PATHNAME)
$srcSheet = $Workbook.Sheets.Item(1)

$startLine = 2
$endLine = $ROW_COUNT_IN_SPREADSHEET
$outLine = 2


For ($i=$startLine; $i -le $endLine; $i++) {
  $content = $srcSheet.Cells.Item($i,1).Text
  if (-not $content) {continue}
  
  $pct = (($i - $startLine) / ($endLine - $startLine)) * 100
  Write-Progress -Activity "[$i] $content" -Status "$pct% complete" -PercentComplete $pct
  $inJsonBody = '{"language": "' + $languageCode + '", "content": "' + $content + '", "settings": {"deterministic": true, "format": "dialogue", "sentiment": false, "snippets":true, "entities": true, "topic_standard":"native", "optimize_topics":true}}'
  $parsedTisane = Invoke-RestMethod -Uri "https://api.tisane.ai/parse" -Method POST -Headers $header -Body $inJsonBody
  $crimeDomain = ''
  $criminalActivity = ''
  $personalAttacks = ''
  $hateSpeech = ''
  $contacts = ''
  $contactDetails = ''
  $sexualAdvances = ''
  $people = ''
  $locations = ''
  $time_ranges = ''
  $dates = ''
  $times = ''
  $files = ''
  $phones = ''
  $orgs = ''
  $software = ''
  if ($parsedTisane.abuse) {
    $parsedTisane.abuse | Foreach-Object {
      $abuseText = $_.text
      $abuseTags = $_.tags
      switch ($_.type) {
        'criminal_activity' {
          $crimePrefix = ''
          if ($abuseTags) {
            $abuseTags | Foreach-Object {
              if ($_ -ne 'addressee' -or $_ -ne 'quantitative') {
              if ($crimePrefix) {
                $crimePrefix = $crimePrefix + '/' + $_
              } else {
                $crimePrefix = $_
              }
              switch ($_) {
                'scam' { $crimeDomain = "fraud 🤥" }
                'soft_drug' { $crimeDomain = "drugs 🌿" }
                'hard_drug' { $crimeDomain = "drugs 💉" }
                'medication' { $crimeDomain = "drugs 💊" }
                'death' { $crimeDomain = "death 💀" }
                'data' { $crimeDomain = "identity and data theft 💳" }
              }
              }
            }
            
          }
          
          if (-not $crimeDomain -and $parsedTisane.topics) {
            $parsedTisane.topics | Foreach-Object {
               switch ($_) {
                'narcotic' { $crimeDomain = "drugs 💉" }
                'drug' { $crimeDomain = "drugs 💉" }
                'soft drug' { $crimeDomain = "drugs 🌿" }
                'hard drug' { $crimeDomain = "drugs 💉" }
                'medication' { $crimeDomain = "drugs 💊" }
                'threat' {$crimeDomain = "threat 👿"}
                'planning' {$crimeDomain = "planning ✍"}
                'sourcing' {$crimeDomain = "procurement 📰"}
                'promotion' {$crimeDomain = "promotion 📢"}
                'child abuse' {$crimeDomain = "child abuse 🚸"}
                'animal' {$crimeDomain = "wildlife and poaching 🦏"}
                'identity theft' {$crimeDomain = "identity and data theft 💳"}
                'credit card' {$crimeDomain = "identity and data theft 💳"}
                'firearm' {$crimeDomain = "firearms 🔫"}
                'cryptocurrency' {$crimeDomain = "cryptocurrency ₿"}
                'fraud' {$crimeDomain = "fraud 🤥"}
                'explosive' {$crimeDomain = "explosives 💣"}
                'explosive device' {$crimeDomain = "explosives 💣"}
                  
              }
           }
          }
          
          if ($crimePrefix -and $criminalActivity.IndexOf($crimePrefix) -lt 0) {
            $criminalActivity = $criminalActivity + ' [' + $crimePrefix + '] ' + $abuseText
          } else {
            $criminalActivity = $criminalActivity + ' ' + $abuseText
          }
        }
        'data' {
          $criminalActivity = $criminalActivity + ' ' + $abuseText
          $crimeDomain = $crimeDomain + " identity and data theft 💳"
        }
        'personal_attack' {
          $personalAttacks = $personalAttacks + " " + $abuseText
        }
        'bigotry' {
          $hateSpeech = $hateSpeech + " " + $abuseText
        }
        'sexual_advances' {
          $sexualAdvances = $sexualAdvances + " " + $abuseText
        }
        'external_contacts' {
          $contacts = $contacts + " " + $abuseText
        }
      }
    }
    
  }
  
  if ($parsedTisane.entities_summary) {
    $parsedTisane.entities_summary | Foreach-Object {
      if ($_.type -eq 'software' -or $_.type[0] -eq 'software' -and $_.type[1] -ne 'website' -and $_.type[2] -ne 'website' -or $_.type[1] -eq 'software' -and $_.type[0] -ne 'website' -and $_.type[2] -ne 'website') {
        if ($software) {
          $software = $software + ' / ' + $_.name
        } else {
          $software = $_.name
        }
      }
      else {
        if ($_.type -eq 'place' -or $_.type[0] -eq 'place' -or $_.type[1] -eq 'place') {
          if ($locations) {
            $locations = $locations + ' / ' + $_.name
          } else {
            $locations = $_.name
          }
        }
        else {
          if ($_.type -eq 'organization' -or $_.type[0] -eq 'organization' -or $_.type[1] -eq 'organization') {
            if ($orgs) {
              $orgs = $orgs + ' / ' + $_.name
            } else {
              $orgs = $_.name
            }
          } else {
            if ($_.type -eq 'person' -or $_.type -eq 'username') {
              if ($people) {
                $people = $people + ' / ' + $_.name
              } else {
                $people = $_.name            
              }
            } else {
              if ($_.type -eq 'email' -or $_.type -eq 'username') {
                if ($contactDetails) {
                  $contactDetails = $contactDetails + ' / ' + $_.name
                } else {
                  $contactDetails = $_.name            
                }
              } else {
                $name = $_.name
                switch ($_.type) 
                { 
                  'crypto' {
                    if (-not($crimeDomain)) {
                      $crimeDomain = "cryptocurrency ₿"
                    }
                  }
                  'time_range' { 
                    if ($time_ranges) {
                      $time_ranges = $time_ranges + ' / ' + $name
                    } else {
                      $time_ranges = $name
                    }
                  }
                  'date' { 
                    if ($dates) {
                      $dates = $dates + ' / ' + $name
                    } else {
                      $dates = $name
                    }
                  }
                  'time' { 
                    if ($times) {
                      $times = $times + ' / ' + $name
                    } else {
                      $times = $name
                    }
                  }
                  'file' {
                    if ($files) {
                      $files = $files + ' / ' + $name
                    } else {
                      $files = $name
                    }
                  }
                  'phone' {
                    if ($phones) {
                      $phones = $phones + ' / ' + $name
                    } else {
                      $phones = $name
                    }
                  }

                }
              }
            }
          }
        }
      }
    }
  }
  $srcSheet.Cells.Item($i,2).Value = $criminalActivity
  $srcSheet.Cells.Item($i,3).Value = $crimeDomain
  $srcSheet.Cells.Item($i,4).Value = $personalAttacks
  $srcSheet.Cells.Item($i,5).Value = $hateSpeech
  $srcSheet.Cells.Item($i,6).Value = $sexualAdvances
  $srcSheet.Cells.Item($i,7).Value = $contacts
  $srcSheet.Cells.Item($i,8).Value = $people
  $srcSheet.Cells.Item($i,9).Value = $orgs
  $srcSheet.Cells.Item($i,10).Value = $software
  $srcSheet.Cells.Item($i,11).Value = $locations
  $srcSheet.Cells.Item($i,12).Value = $time_ranges
  $srcSheet.Cells.Item($i,13).Value = $dates
  $srcSheet.Cells.Item($i,14).Value = $times
  $srcSheet.Cells.Item($i,15).Value = $files
  $srcSheet.Cells.Item($i,16).Value = $phones
}

Write-Progress -Activity "Almost done" -Status "Saving the spreadsheet"


$Workbook.SaveAs($outFilename)
$workbook.Close($false)
[void][System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$Excel)
[gc]::Collect()
[gc]::WaitForPendingFinalizers()
Remove-Variable excel -ErrorAction SilentlyContinue
