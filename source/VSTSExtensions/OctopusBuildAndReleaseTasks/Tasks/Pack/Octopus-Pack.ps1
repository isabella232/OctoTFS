﻿param(
	[string] [Parameter(Mandatory = $true)]
	$PackageId,
	[string] [Parameter(Mandatory = $true)]
	$PackageFormat,
	[string] [Parameter(Mandatory = $false)]
	$PackageVersion,
	[string] [Parameter(Mandatory = $false)]
	$SourcePath,
	[string] [Parameter(Mandatory = $false)]
	$OutputPath,
	[string] [Parameter(Mandatory = $false)]
	$Include,
	[string] [Parameter(Mandatory = $false)]
	$Overwrite,
	[string] [Parameter(Mandatory = $false)]
	$NuGetAuthor,
	[string] [Parameter(Mandatory = $false)]
	$NugetTitle,
	[string] [Parameter(Mandatory = $false)]
	$NugetDescription,
	[string] [Parameter(Mandatory = $false)]
	$NuGetReleaseNotes,
	[string] [Parameter(Mandatory = $false)]
	$NuGetReleaseNotesFile
)

Write-Verbose "Entering script Octopus-Pack.ps1"

$agentWorkerModulesPath = "$($env:AGENT_HOMEDIRECTORY)\agent\worker\Modules"
$tfsInternalModulePath = "$agentWorkerModulesPath\Microsoft.TeamFoundation.DistributedTask.Task.Internal\Microsoft.TeamFoundation.DistributedTask.Task.Internal.dll"
$tfsCommonModulePath = "$agentWorkerModulesPath\Microsoft.TeamFoundation.DistributedTask.Task.Common\Microsoft.TeamFoundation.DistributedTask.Task.Common.dll"
Write-Verbose "Importing modules"
Import-Module $tfsInternalModulePath
Import-Module $tfsCommonModulePath

# Returns a path to the Octo.exe file
function Get-PathToOctoExe() {
	$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.ScriptBlock.File
	$targetPath = Join-Path -Path $PSScriptRoot -ChildPath "Octo.exe" 
	return $targetPath
}

# Call Octo.exe
$octoPath = Get-PathToOctoExe
Write-Output "Path to Octo.exe = $octoPath"
$Overwrite = [System.Convert]::ToBoolean($Overwrite)
$Arguments = "pack --id=`"$PackageId`" --format=$PackageFormat --version=$PackageVersion --outFolder=`"$OutputPath`" --basePath=`"$SourcePath`" --author=`"$NugetAuthor`" --title=`"$NugetTitle`" --description=`"$NugetDescription`" --releaseNotes=`"$NuGetReleaseNotes`" --releaseNotesFile=`"$NugetReleaseNotesFile`" --overwrite=$Overwrite" 
if ($Include) {
   ForEach ($IncludePath in $Include.replace("`r", "").split("`n")) {
   $Arguments = $Arguments + " --include=`"$IncludePath`""
   }
}

Invoke-Tool -Path $octoPath -Arguments $Arguments 

Write-Verbose "Completed Octopus-Pack.ps1"