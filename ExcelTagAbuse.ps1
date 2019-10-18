
# modify the 4 parameters below as you need. Assuming your samples are in the first column

$SPREADSHEET_PATHNAME = 'c:\PATH_WHERE_I_STORE_MY_SPREADSHEETS\TisaneTest.xlsx'
$TISANE_PATH = 'C:\Tisane\TestConsole\'
$ROW_COUNT_IN_SPREADSHEET = 1000
$languageCode = 'en' # assuming the spreadsheets are monolingual



$Excel = New-Object -ComObject Excel.Application
$Workbook = $Excel.Workbooks.Open($SPREADSHEET_PATHNAME)
$srcSheet = $Workbook.Sheets.Item(1)
$config_path = $TISANE_PATH + "Tisane.TestConsole.exe.Config"

[System.AppDomain]::CurrentDomain.SetData("APP_CONFIG_FILE", $config_path) # assign the configuration file

# BEGIN fix for Powershell bug: in some cases, the configuration files aren't read properly
Add-Type -AssemblyName System.Configuration
[Configuration.ConfigurationManager].GetField("s_initState", "NonPublic, Static").SetValue($null, 0)
[Configuration.ConfigurationManager].GetField("s_configSystem", "NonPublic, Static").SetValue($null, $null)
([Configuration.ConfigurationManager].Assembly.GetTypes() | where {$_.FullName -eq "System.Configuration.ClientConfigPaths"}).GetField("s_current", "NonPublic, Static").SetValue($null, $null)
[Configuration.ConfigurationManager]::ConnectionStrings[0].Name
# END fix for Powershell bug: in some cases, the configuration files aren't read properly

[Reflection.Assembly]::LoadFrom($tisane_path + "Tisane.Runtime.dll") # load the type

$tisane = New-Object Tisane.Server
Write-Progress -Activity "Loading language model" -Status "Normally takes 30-40 sec"
$doesntMatter = $tisane.Parse($languageCode, 'Testing', '{}')
$startLine = 2
$endLine = $ROW_COUNT_IN_SPREADSHEET
$outLine = 2


For ($i=$startLine; $i -le $endLine; $i++) {
  $content = $srcSheet.Cells.Item($i,1).Text
  if (-not $content) {continue}
  
  $pct = (($i - $startLine) / ($endLine - $startLine)) * 100
  Write-Progress -Activity "[$i] $content" -Status "$pct% complete" -PercentComplete $pct
  $tisaneResult = $tisane.Parse($languageCode, $content, '{"snippets":true,"topic_standard":"native","sentiment":false,"parses":false,"words":true,"entities":true}')
  $tisaneResult
  $parsedTisane = ConvertFrom-Json -InputObject $tisaneResult
  $crimeDomain = ''
  $criminalActivity = ''
  $personalAttacks = ''
  $hateSpeech = ''
  $contacts = ''
  $contactDetails = ''
  $sexualAdvances = ''
  $people = ''
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
            if ($_.type -eq 'email' -or $_.type -eq 'phone' -or $_.type -eq 'username') {
              if ($contactDetails) {
                $contactDetails = $contactDetails + ' / ' + $_.name
              } else {
                $contactDetails = $_.name            
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
}

Write-Progress -Activity "Almost done" -Status "Saving the spreadsheet"


$Workbook.Save()
$workbook.Close($false)
[void][System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$Excel)
[gc]::Collect()
[gc]::WaitForPendingFinalizers()
Remove-Variable excel -ErrorAction SilentlyContinue
