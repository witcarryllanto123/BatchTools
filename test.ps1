# Set the directory where your .whl files are located
$directory = "L:\Git Repository\Package5"

# List of essential .whl files for REMBG
$essentialFiles = @(
    "numpy-2.1.3-cp312-cp312-win_amd64.whl",
    "scikit_image-0.25.2-cp312-cp312-win_amd64.whl",
    "opencv_python_headless-4.11.0.86-cp37-abi3-win_amd64.whl",
    "pillow-11.1.0-cp312-cp312-win_amd64.whl",
    "numba-0.61.0-cp312-cp312-win_amd64.whl",
    "requests-2.32.3-py3-none-any.whl"
)

# Get all .whl files from the directory
$whlFiles = Get-ChildItem -Path $directory -Filter *.whl

# Loop through all .whl files
foreach ($file in $whlFiles) {
    if ($file.Name -notin $essentialFiles) {
        Write-Host "Deleting unnecessary file: $($file.Name)" -ForegroundColor Red
        Remove-Item -Path $file.FullName -Force
    } else {
        Write-Host "Keeping essential file: $($file.Name)" -ForegroundColor Green
    }
}
