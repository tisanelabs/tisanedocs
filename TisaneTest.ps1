$tisane_path = "C:\Tisane\" # if Tisane is elsewhere, change this
$config_path = $tisane_path + "Tisane.TestConsole.exe.Config" # assuming the TestConsole config exists
[System.AppDomain]::CurrentDomain.SetData("APP_CONFIG_FILE", $config_path) # assign the configuration file
[Reflection.Assembly]::LoadFrom($tisane_path + "Tisane.Runtime.dll") # load the type

$startedAt = Get-Date
$tisane = New-Object Tisane.Server 
$languageCode = 'en'
$textToParse = 'People like you should be executed'
$tisaneResult = $tisane.Parse($languageCode, $textToParse, '{"snippets":true,"topic_standard":"native","sentiment":false,"parses":false,"words":false,"entities":true}')
$tisaneResult
$finishedAt = Get-Date
$timeTaken = ($finishedAt - $startedAt).TotalSeconds
"Done $timeTaken seconds"
