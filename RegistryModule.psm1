#------------------------------------------------------------------------------
# RegistryModule.psm1
#
#
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function Test-RegPath
#
# Test is the registry key exists
#------------------------------------------------------------------------------

function Test-RegPath

{
	Param ( [String]$ComputerName = '.',
			[String]$Hive,
			[String]$RegKey )
	
	if ( $ComputerName -eq '.' ) { 			# ----- Test Local computer registry
						
			$TorF = Test-Path $RegKey 
		}	
		else {								# ----- Test Remote Computer Registry
			$regHive = [Microsoft.Win32.RegistryHive]$hive
			$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey( $RegHive, $ComputerName )         
 			$regKey= $reg.OpenSubKey( $RegKey )      
 			if (!$regKey ){
					$TorF = $False
				}
				else { 
					$TorF = $True
			} 
	}
	
	Return $TorF
}

#------------------------------------------------------------------------------
# Function Set-RegistryKey
#
#------------------------------------------------------------------------------

<# 
	.SYNOPSIS 
		Sets a registry key. 
	.DESCRIPTION 
		The SetRegistryKey function replaces a value on an existing key or creates a key that contains a value. 
	.PARAMETER Key 
		The registry key path. 
	.PARAMETER Name 
		The name of the registry property. 
	.PARAMETER Value 
		The registry key property value. 
	.PARAMETER Type 
		The registry property type. 
	.EXAMPLE 
		SetRegistryKey -Key 'HKCU:\Software\Foo' -Name Bar -Value null
		
		Sets the registry key "HKCU:\Software\Foo" property "Bar" to the value "null" 
	.LINK
		http://blogs.technet.com/b/heyscriptingguy/archive/2010/05/31/hey-scripting-guy-how-can-i-write-to-the-registry-with-windows-powershell-2-0.aspx
#>


function Set-Registrykey {

	param ( [String]$RegKey,
			[String]$RegName,
			[String]$RegValue,
			[Microsoft.Win32.RegistryValueKind]$RegType,
			[String]$ComputerName = '.' )
	
	# ----- Test for the registry key path and create it if the test fails
	if ( -not( Test-Path $RegKey ) ) {
		New-Item $Key -ItemType Registry -Force | Out-Null
	}
	
	# ----- Creates or replaces teh registry Property value
	New-ItemProperty $RegKey -Name $RegName -Value $RegValue -PropertyType $RegType -Force | out-null
}

#------------------------------------------------------------------------------
# Function Get-RegistryKey
#
#------------------------------------------------------------------------------

<# 
	.SYNOPSIS 
		Reads from the registry. 
	.DESCRIPTION 
		Reads from the registry.  Gets all the keys values or just one specific property's value. 
	.PARAMETER RegKey 
		The registry key path. 
	.PARAMETER RegName 
		The name of the registry property. 
	.PARAMETER ComputerName
		To be used in future updates 
	.EXAMPLE 
		Get-RegistryKey -RegKey 'HKCU:\Software\Foo' 
		
		Gets the registry key "HKCU:\Software\Foo" propertys
	.LINK
		http://www.vistax64.com/powershell/9086-reading-writing-registry-values.html
#>
	
	
Function Get-RegistryKey {

	param ( [String]$RegKey,
			[String]$RegName = $Null,
			[String]$ComputerName = '.' )
			
	$null = New-PSDrive -Name HKU   -PSProvider Registry -Root Registry::HKEY_USERS 
	$null = New-PSDrive -Name HKCR -PSProvider Registry -Root Registry::HKEY_CLASSES_ROOT 
	$null = New-PSDrive -Name HKCC -PSProvider Registry -Root Registry::HKEY_CURRENT_CONFIG
	
	if ( $RegName ) {
			return (Get-Item $Regkey).getvalue($RegName)
		}
		else {
			return ( Get-ItemProperty $RegKey )
	}
}

#------------------------------------------------------------------------------

Export-ModuleMember -Function Get-RegistryKey, Set-RegistryKey, Test-RegPath