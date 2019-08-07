$tisane_path = "C:\Tisane\TestConsole\"
$config_path = $tisane_path + "Tisane.TestConsole.exe.Config"
[System.AppDomain]::CurrentDomain.SetData("APP_CONFIG_FILE", $config_path)
[Reflection.Assembly]::LoadFrom($tisane_path + "Tisane.TestConsole.exe")
[Reflection.Assembly]::LoadFrom($tisane_path + "Tisane.Runtime.dll")
# Add-Type -Path c:\Tisane\TestConsole\Tisane.Runtime.dll
$tisane = New-Object Tisane.Server
$languageCode = 'en'
$textToParse = 'we must secure our borders #killallbabylonians'
$tisaneResult = $tisane.Parse($languageCode, $textToParse, '{"domain_factors":{"43297":5.0,"15812":4.0,"55671":5.0,"15956":3.0,"81198":4.9,"34122":5.0},"snippets":true,"topic_standard":"native","sentiment":false,"parses":false,"words":false,"entities":true}')
$tisaneResult