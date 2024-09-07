$MD = (Get-Content $PSScriptRoot/resources.md -Raw) -split '\n#'

foreach ($Entry in $MD) {
    $Arr = $MD[0] -split '\n'
    $Mark = $Arr | ConvertFrom-Markdown
    $Mark.H1 = $Arr[0]
    $Mark
}