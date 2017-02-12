<#
.DESCRIPTION
Compress log files into zip archives and delete archived logs with date stamps
older than a specified number of days.
.SYNOPSIS
Run this PowerShell script daily as a scheduled task to clean up log files.

This script uses file datestamps to evaluate if log files should be archived
into zip files, or deleted due to aging.

For any log file not having a date stamp from today, archive those files
individually.  By default, any archived log files older than seven days are
removed to conserve disk space.

See parameters for overrides to default behaviors.
.PARAMETER pathName
Specify a file system path name to where log files are located.  Defaults to
working directory.
.PARAMETER fileExtension
Specify a file extension to use for recognizing log files.  Defaults to 'txt'.
.PARAMETER days
Specify the number of days to keep archives before removing them.
.EXAMPLE
 ./Start-LogRotator

 This will compress .txt files that do not have today's date stamp found in the
 same directory as this PowerShell script.  Archives older than 7 days are
 deleted.
.EXAMPLE
 ./Start-LogRotator -pathName 'C:\Users\dcs\Saved Games\DCS\Slmod\Chat Logs'

 This will compress logs found in the Chat Logs folder.  Other default options
 apply.
.EXAMPLE
 ./Start-LogRotator -pathName 'C:\Users\dcs\Saved Games\DCS\Logs' -fileType
 'log' -days 3

 This will compress files with the .log extension in the Logs folder.  Archives
 older than three days are removed.
.NOTES
This script requires PowerShell version 5.0 to function.
#>

# Thomas Dye, February 2017


#Define the input parameters.  Parameters are optional.
param (
    [string]$pathName = '.',
    [string]$fileType = 'txt',
    [int]$days = 7
)

#Get today's date for comparing files
$now = Get-Date

#Build the file extension of log files based off of the file type supplied
$fileExtension = "*.$fileType"

#Filter for files needing to be compressed
$dateFilesToArchive = $now.AddDays(-1)

#Filter for files needing to be removed
$dateFilesToRemove = $now.AddDays(-$days)

#Collection of log all files to archive
$archiveFiles = Get-ChildItem $pathName $fileExtension | Where-Object { $_.LastWriteTime -le "$dateFilesToArchive" }

#Collection of all log files to remove due to aging
$removeFiles = Get-ChildItem $pathName "*.zip" | Where-Object { $_.LastWriteTime -le "$dateFilesToRemove" }

#Begin archiving of log files
foreach ($file in $archiveFiles)
{
    if ($file -ne $NULL)
    {
        $fileName = $file.BaseName
        Compress-Archive -Path $pathName/$file -DestinationPath "$pathName/$fileName.zip"
        Remove-Item $file.FullName
    }
}

#Begin removing old archive files
foreach ($file in $removeFiles)
{
    if ($file -ne $NULL)
    {
        Remove-Item $file.FullName
    }
}