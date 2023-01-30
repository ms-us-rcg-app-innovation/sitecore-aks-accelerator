function ConvertTo-CompressedBase64String {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [ValidateScript( {
            if (-Not ($_ | Test-Path) ) {
                throw "The file or folder $_ does not exist"
            }
            if (-Not ($_ | Test-Path -PathType Leaf) ) {
                throw "The Path argument must be a file. Folder paths are not allowed."
            }
            return $true
        })]
        [string] $Path
    )
    # read the file into a byte array
    $fileBytes = [System.IO.File]::ReadAllBytes($Path)

    # create a memory stream for the bytes
    [System.IO.MemoryStream] $memoryStream = New-Object System.IO.MemoryStream

    # gzip the bytes
    $gzipStream = New-Object System.IO.Compression.GzipStream $memoryStream, ([IO.Compression.CompressionMode]::Compress)
    $gzipStream.Write($fileBytes, 0, $fileBytes.Length)
    $gzipStream.Close()
    $memoryStream.Close()

    # get the underlying compressed bytes
    $compressedFileBytes = $memoryStream.ToArray()

    # encode to base64
    $encodedCompressedFileData = [Convert]::ToBase64String($compressedFileBytes)
    $gzipStream.Dispose()
    $memoryStream.Dispose()
    
    return $encodedCompressedFileData
   }
   