# Load necessary Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Pick an Event"
$form.Size = New-Object System.Drawing.Size(350, 400)
$form.StartPosition = "CenterScreen"

# Create a group box to hold the radio buttons
$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.Text = "Choose an option:"
$groupBox.Size = New-Object System.Drawing.Size(300, 80)
$groupBox.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($groupBox)

# Create a radio button for "AI Masterclass"
$radioAIMasterclass = New-Object System.Windows.Forms.RadioButton
$radioAIMasterclass.Text = "AI Masterclass"
$radioAIMasterclass.Location = New-Object System.Drawing.Point(20, 30)
$radioAIMasterclass.Checked = $true  # Set as default
$groupBox.Controls.Add($radioAIMasterclass)

# Create a radio button for "AMEvents"
$radioAMEvents = New-Object System.Windows.Forms.RadioButton
$radioAMEvents.Text = "AMEvents"
$radioAMEvents.Location = New-Object System.Drawing.Point(150, 30)
$groupBox.Controls.Add($radioAMEvents)

# Create checkboxes for tasks below the radio buttons
$global:checkboxes = @()

# Function to create and add checkboxes to the form
function Add-Checkbox {
    param ($text, $x, $y)
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $text
    $checkbox.Location = New-Object System.Drawing.Point($x, $y)
    $checkbox.Size = New-Object System.Drawing.Size(250, 20)
    $checkbox.Checked = $true  # Pre-check the checkbox
    $form.Controls.Add($checkbox)
    $global:checkboxes += $checkbox
}

# Add checkboxes for various tasks (pre-checked by default)
Add-Checkbox "Uninstall Office" 20 110
Add-Checkbox "Install Office" 20 140
Add-Checkbox "Install Chrome" 20 170
Add-Checkbox "Pause automatic updates" 20 200
Add-Checkbox "Install Templates" 20 230
Add-Checkbox "Install Fonts" 20 260



# Create the "Install" button
$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = "Install"
$installButton.Location = New-Object System.Drawing.Point(125, 290)
$installButton.Size = New-Object System.Drawing.Size(100, 30)
$form.Controls.Add($installButton)



# Event handler for the "Install" button
$installButton.Add_Click({
        # Capture selected radio button
        if ($radioAIMasterclass.Checked) {
            AIMasterclass
        }
        elseif ($radioAMEvents.Checked) {
            AMEvents
        }

        # Capture selected checkboxes
        $selectedTasks = @()
        foreach ($checkbox in $global:checkboxes) {
            if ($checkbox.Checked) {
                switch ($checkbox.Text) {
                    "Uninstall Office" { Uninstall-Office }
                    "Install Office" { Install-Office }
                    "Install Chrome" { Install-Chrome }
                    "Pause automatic updates" { Suspend-AutoUpdates }
                    "Install Templates" { Install-Templates }
                    "Install Fonts" { Install-Fonts }
                }
            
                $selectedTasks += $checkbox.Text
            }
        }

        [System.Windows.Forms.MessageBox]::Show("All tasks have been completed successfully.")
    })

# Check if the script is running with administrator privileges.
function Test-Admin {
    # Check if the current user is an administrator
    $isAdmin = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if ($isAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "The script is running with administrator privileges."
        return $true
    }
    else {
        Write-Host "The script is NOT running with administrator privileges."
        return $false
    }
}

function Test-InternetConnection {
    param (
        [string]$TestHost = "www.google.com"  # Default host to test
    )

    try {
        $pingResult = Test-Connection -ComputerName $TestHost -Count 2 -ErrorAction Stop
        if ($pingResult) {
            Write-Host "Internet connection is active."
            return $true
        }
    }
    catch {
        $message = "Internet connection not detected. Please check your Wi-Fi or Ethernet connection, and ensure that your router is powered on."
        Write-Host "Internet connection is NOT active."
        [System.Windows.Forms.MessageBox]::Show($message)
        $form.Close()
        return $false
    }
}

function AIMasterclass {
    param (
        [string]$FolderName = "Fonts"  # Name of the folder to copy
    )

    # Get the script's directory
    $scriptPath = $PSScriptRoot

    # Get the source folder path
    $sourceFolder = Join-Path -Path $scriptPath -ChildPath $FolderName

    # Get the path to the desktop
    $desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, 'Desktop')

    # Build the destination path
    $destinationFolder = Join-Path -Path $desktopPath -ChildPath $FolderName

    # Check if the source folder exists
    if (-Not (Test-Path $sourceFolder)) {
        Write-Host "Source folder not found: $sourceFolder" -ForegroundColor Red
        return
    }

    # Copy the folder and all its subfolders to the desktop
    try {
        Copy-Item -Path $sourceFolder -Destination $destinationFolder -Recurse -Force
        Write-Host "Folder copied to desktop: $destinationFolder" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to copy folder: $_" -ForegroundColor Red
    }
}

function AMEvents {

    param (
        [string]$SourceFilePath = "$PSScriptRoot\caffeine.exe"  # Full path of the file to copy
    )
    
    # Get the user's startup folder path
    $startupFolder = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup')
    
    # Check if the source file exists
    if (-Not (Test-Path $SourceFilePath)) {
        Write-Host "Source file not found: $SourceFilePath" -ForegroundColor Red
        return
    }
    
    # Build the destination path in the startup folder
    $destinationFilePath = [System.IO.Path]::Combine($startupFolder, [System.IO.Path]::GetFileName($SourceFilePath))
    
    # Copy the file to the startup folder
    try {
        Copy-Item -Path $SourceFilePath -Destination $destinationFilePath -Force
        Write-Host "File copied to startup folder: $destinationFilePath" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to copy file: $_" -ForegroundColor Red
    }
}


function Uninstall-Office {
    Write-Host "Not Implemented"
}

function Install-Office {
    Write-Host "Not Implemented"
}

function Install-Chrome {
    $Path = $env:TEMP
    $Installer = 'chrome_installer.exe'
    try {
        # Download the Chrome installer
        Write-Host "Downloading Google Chrome installer..."
        Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/375.126/chrome_installer.exe' -OutFile $Path\$Installer
    
        # Start the installation process silently
        Write-Host "Installing Google Chrome..."
        #Start-Process -FilePath $Path\$Installer -Args '/silent /install' -Verb RunAs -Wait
    
        # Remove the installer after installation
        Remove-Item -Path $Path\$Installer -Force
        Write-Host "Chrome has been installed successfully."

    }
    catch [System.Net.WebException] {
        Write-Error "Network error occurred while downloading the installer: $_. Exception message: $($_.Exception.Message)"
        Add-Content -Path $LogFile -Value "Network error: $($_.Exception.Message)"
    }
    catch [System.Exception] {
        Write-Error "An error occurred during the installation: $_. Exception message: $($_.Exception.Message)"
        Add-Content -Path $LogFile -Value "Installation error: $($_.Exception.Message)"
    }
    finally {
        # Ensure cleanup even if there was an error
        if (Test-Path "$Path\$Installer") {
            Remove-Item -Path "$Path\$Installer" -Force -ErrorAction SilentlyContinue
        }
    }
}

#Pause updates for 35 days
function Suspend-AutoUpdates {

    # Registry path for Group Policy updates
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    # Create the registry key if it doesn't exist
    if (-Not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force
    }

    # Set the pause for both quality and feature updates
    Set-ItemProperty -Path $regPath -Name "DeferFeatureUpdates" -Value 1 -Force
    Set-ItemProperty -Path $regPath -Name "DeferQualityUpdates" -Value 1 -Force
    Set-ItemProperty -Path $regPath -Name "DeferUpdatePeriodInDays" -Value 35 -Force

    Write-Host "Windows updates have been paused for 35 days via Group Policy." -ForegroundColor Green
    gpupdate /force
}

function Install-Templates {
    param (
        [string]$SourceDirectory = "$PSScriptRoot\Templates", # Default to a Templates subdirectory in the script directory
        [string]$TargetDirectory = "$env:USERPROFILE\Documents\Templates"  # Default target directory
    )

    # Check if the source directory exists
    if (-Not (Test-Path $SourceDirectory)) {
        Write-Error "The specified source directory does not exist: $SourceDirectory"
        return
    }

    # Ensure the target directory exists; create it if it doesn't
    if (-Not (Test-Path $TargetDirectory)) {
        New-Item -Path $TargetDirectory -ItemType Directory | Out-Null
        Write-Host "Created target directory: $TargetDirectory"
    }

    # Get all template files in the source directory
    $templateFiles = Get-ChildItem -Path $SourceDirectory -File

    if ($templateFiles.Count -eq 0) {
        Write-Host "No template files found in the directory: $SourceDirectory"
        return
    }

    # Install each template
    foreach ($template in $templateFiles) {
        try {
            # Copy the template file to the target directory
            Copy-Item -Path $template.FullName -Destination $TargetDirectory -Force
            Write-Host "Installed template: $($template.Name)"
        }
        catch {
            Write-Error "Failed to install template '$($template.Name)': $_"
        }
    }

    Write-Host "Template installation completed."
}

function Install-Fonts {
    param (
        [string]$FontDirectory = $PSScriptRoot,
        [string]$FontsPath = "C:\Windows\Fonts"
    )

    # Check if the specified directory exists
    if (-Not (Test-Path $FontDirectory)) {
        Write-Error "The specified font directory does not exist: $FontDirectory"
        return
    }

    # Get all font files in the specified directory
    $fontFiles = Get-ChildItem -Path $FontDirectory -Recurse -Include *.ttf, *.otf -File

    if ($fontFiles.Count -eq 0) {
        Write-Host "No font files found in the directory: $FontDirectory"
        return
    }

    # Install each font
    foreach ($font in $fontFiles) {
        try {
            # Copy the font file to the Windows Fonts directory
            Copy-Item -Path $font.FullName -Destination $FontsPath -Force
            
            # Register the font with Windows
            $fontRegKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
            $fontName = [System.IO.Path]::GetFileNameWithoutExtension($font.Name)
            Set-ItemProperty -Path $fontRegKey -Name "$fontName (TrueType)" -Value $font.Name

            Write-Host "Installed font: $fontName"
        }
        catch {
            Write-Error "Failed to install font '$($font.Name)': $_"
        }
    }

    Write-Host "Font installation completed."
}


#Check Admin Rights
if (-Not (Test-Admin)) {
    $message = "Please run the script with administrator privileges."
    [System.Windows.Forms.MessageBox]::Show($message)
    $form.Close()
    Write-Host $message
    exit
}

# Call the function to test the internet connection
Test-InternetConnection
# Show the form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
