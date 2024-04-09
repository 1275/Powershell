<#
.SYNOPSIS
This script compresses a specified directory into a ZIP file, places it in a specified destination, 
names the ZIP file as specified and then calculates and saves the file's hash.

.DESCRIPTION
The CompressAndHash.ps1 script takes a directory path, destination path and archive name as input. 
It compresses the directory into a ZIP file, moves the ZIP file to the destination, and names it according to the input. 
It then calculates the SHA256 hash of the ZIP file and saves this hash to a .txt file in the same location as the ZIP file.

.PARAMETER path
The path of the directory you want to compress.

.PARAMETER DestinationPath
The destination path where you want to store the ZIP file.

.PARAMETER ArchiveName
The name you want to give to your ZIP file. ".zip" will be appended if not included.

.PARAMETER Replace
Specifies whether to replace an existing ZIP file with the same name in the destination path. 
If set to "R", the existing ZIP file will be replaced. 
If not provided or set to any other value, the user will be prompted to confirm before replacing the existing ZIP file. 

.EXAMPLE
.\CompressAndHash.ps1 -path "C:\temp" -DestinationPath "C:\temp\new" -ArchiveName "Archive"
.\CompressAndHash.ps1 -path "C:\temp" -DestinationPath "C:\temp\new" -ArchiveName "Archive" -Replace R

This command compresses the C:\temp directory, places the ZIP file in C:\temp\new, 
names it "Archive.zip", calculates the file's hash, and saves the hash to a text file.

.NOTES
Author: 1275
Date:   2024-04-09 
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [Parameter(Mandatory=$true)]
    [string]$DestinationPath,
    [Parameter(Mandatory=$true)]
    [string]$ArchiveName,
    [string]$Replace = ""
)

# Check for minimum required PowerShell version
$minVersion = [Version]"5.0"
$currentVersion = $PSVersionTable.PSVersion

if ($currentVersion -lt $minVersion) {
    Write-Error "This script requires at least PowerShell version $minVersion. Current version is $currentVersion."
    exit
}
# Ensuring the ArchiveName ends with .zip
if (-not $ArchiveName.EndsWith(".zip")) {
    $ArchiveName += ".zip"
}
# Ensuring DestinationPath directory exists
if (-not (Test-Path -Path $DestinationPath)) {
    New-Item -ItemType Directory -Path $DestinationPath
}

# Full path for the output ZIP file
$fullOutputPath = Join-Path -Path $DestinationPath -ChildPath $ArchiveName

if (Test-Path -Path $fullOutputPath) {
    if ($Replace -ne "R") {
        $Replace = Read-Host "The ZIP file already exists. Enter 'R' to replace it, or any other key to cancel"
    }
    if ($Replace -eq "R") {
        # Replace the existing archive
        Remove-Item -Path $fullOutputPath -Force
        Compress-Archive -Path $Path -DestinationPath $fullOutputPath -CompressionLevel Optimal
    } else {
        Write-Output "Operation canceled by the user."
        exit
    }
} else {
    # Archive does not exist, proceed to compress
    Compress-Archive -Path $Path -DestinationPath $fullOutputPath -CompressionLevel Optimal
}

# Generating the file hash
$fileHash = Get-FileHash -Path $fullOutputPath -Algorithm SHA256

# Writing the hash to a hash.txt file in the same directory as the .zip file
$hashFilePath = Join-Path -Path $DestinationPath -ChildPath "$($ArchiveName.Replace('.zip', ''))-hash.txt"
$fileHash.Hash | Out-File -FilePath $hashFilePath
https://github.com/1275/Powershell
# Outputting the location of the hash file
Write-Output "The hash of the ZIP file has been saved to: $hashFilePath"
