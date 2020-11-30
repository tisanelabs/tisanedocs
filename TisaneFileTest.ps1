Param(
     [Parameter(HelpMessage="Input file")][String] $pathname,
     [Parameter(HelpMessage="Language")][String] $language
)

$tisane_path = "C:\Tisane\TestConsole\"
$config_path = $tisane_path + "Tisane.TestConsole.exe.config"
[System.AppDomain]::CurrentDomain.SetData("APP_CONFIG_FILE", $config_path)
Add-Type -AssemblyName System.Configuration
Add-Type -AssemblyName System.Web
[Configuration.ConfigurationManager].GetField("s_initState", "NonPublic, Static").SetValue($null, 0)
[Configuration.ConfigurationManager].GetField("s_configSystem", "NonPublic, Static").SetValue($null, $null)
([Configuration.ConfigurationManager].Assembly.GetTypes() | where {$_.FullName -eq "System.Configuration.ClientConfigPaths"}).GetField("s_current", "NonPublic, Static").SetValue($null, $null)
[Configuration.ConfigurationManager]::ConnectionStrings[0].Name
[Reflection.Assembly]::LoadFrom($tisane_path + "Tisane.Runtime.dll")

$content = Get-Content $pathname -encoding UTF8 | Out-String
#$content = [System.Web.HttpUtility]::HtmlDecode($content).Replace('&quot;', '"')
try {
  $tisane = New-Object Tisane.Server
  [Tisane.Server]::ActivateLazyLoading()
  $content = $tisane.Normalize($tisane.ExtractText($content))
  $json = $tisane.Parse($language, $content, '{"parses":false,"words":false}')
  $json
}
catch {
  # $_  | Select-Object -Property *
  Write-Host $_.Exception
}
