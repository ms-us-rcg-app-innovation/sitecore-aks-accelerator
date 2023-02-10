param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$Output
)

$licenseFileStream = [System.IO.File]::OpenRead($Path);
$licenseString = $null

try
{
    $memory = [System.IO.MemoryStream]::new()

    $gzip = [System.IO.Compression.GZipStream]::new($memory, [System.IO.Compression.CompressionLevel]::Optimal, $false);
    $licenseFileStream.CopyTo($gzip);
    $gzip.Close();

    # base64 encode the gzipped content
    $licenseString = [System.Convert]::ToBase64String($memory.ToArray())
}
finally
{
    # cleanup
    if ($null -ne $gzip)
    {
        $gzip.Dispose()
        $gzip = $null
    }

    if ($null -ne $memory)
    {
        $memory.Dispose()
        $memory = $null
    }

    $licenseFileStream = $null
}

# sanity check
if ($licenseString.Length -le 100)
{
    throw "Unknown error, the gzipped and base64 encoded string '$licenseString' is too short."
}

Set-Content -Path $Output -Value $licenseString