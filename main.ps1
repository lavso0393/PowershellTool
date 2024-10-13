# Load necessary Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Pick an Event"
$form.Size = New-Object System.Drawing.Size(350,400)
$form.StartPosition = "CenterScreen"

# Create a group box to hold the radio buttons
$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.Text = "Choose an option:"
$groupBox.Size = New-Object System.Drawing.Size(300,80)
$groupBox.Location = New-Object System.Drawing.Point(20,20)
$form.Controls.Add($groupBox)

# Create a radio button for "AI Masterclass"
$radioAIMasterclass = New-Object System.Windows.Forms.RadioButton
$radioAIMasterclass.Text = "AI Masterclass"
$radioAIMasterclass.Location = New-Object System.Drawing.Point(20,30)
$radioAIMasterclass.Checked = $true  # Set as default
$groupBox.Controls.Add($radioAIMasterclass)

# Create a radio button for "AMEvents"
$radioAMEvents = New-Object System.Windows.Forms.RadioButton
$radioAMEvents.Text = "AMEvents"
$radioAMEvents.Location = New-Object System.Drawing.Point(150,30)
$groupBox.Controls.Add($radioAMEvents)

# Create checkboxes for tasks below the radio buttons
$global:checkboxes = @()

# Function to create and add checkboxes to the form
function Add-Checkbox {
    param ($text, $x, $y)
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $text
    $checkbox.Location = New-Object System.Drawing.Point($x, $y)
    $checkbox.Size = New-Object System.Drawing.Size(250,20)
    $checkbox.Checked = $true  # Pre-check the checkbox
    $form.Controls.Add($checkbox)
    $global:checkboxes += $checkbox
}

# Add checkboxes for various tasks (pre-checked by default)
Add-Checkbox "Uninstall Office" 20 110
Add-Checkbox "Install Office" 20 140
Add-Checkbox "Install Chrome" 20 170
Add-Checkbox "Disable automatic updates" 20 200
Add-Checkbox "Install EY Templates" 20 230
Add-Checkbox "Install EY Fonts" 20 260



# Create the "Install" button
$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = "Install"
$installButton.Location = New-Object System.Drawing.Point(125,290)
$installButton.Size = New-Object System.Drawing.Size(100,30)
$form.Controls.Add($installButton)



# Event handler for the "Install" button
$installButton.Add_Click({
    # Capture selected radio button
    if ($radioAIMasterclass.Checked) {
        $selectedEvent = "AI Masterclass"
        
    } elseif ($radioAMEvents.Checked) {
        $selectedEvent = "AMEvents"
    }

    # Capture selected checkboxes
    $selectedTasks = @()
    foreach ($checkbox in $global:checkboxes) {
        if ($checkbox.Checked) {
            switch ($checkbox.Text) {
                "Uninstall Office" {f1}
                "Install Office"   {f2}
                "Install Chrome"   {Install-Chrome}
                "Disable automatic updates"  {Pause-AutoUpdates}
                "Install EY Templates" {f5}
                "Install EY Fonts" {f6}
            }
            $selectedTasks += $checkbox.Text
        }
    }

    # Display the chosen event and selected tasks
    $message = "You picked $selectedEvent.`nSelected tasks:"
    if ($selectedTasks.Count -eq 0) {
        $message += "`nNone"
    } else {
        $message += "`n" + ($selectedTasks -join "`n")
    }

    Write-Host $message
    # Show the message box
    #[System.Windows.Forms.MessageBox]::Show($message)
    #$form.Close()
})





function Pause-AutoUpdates{
    # Define the maximum pause period (35 days)
    $Days = 35

    # Calculate the date to pause updates until
    $PauseEndDate = (Get-Date).AddDays($Days)

    # Set the Windows Update pause date in the registry
    #Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "PauseFeatureUpdatesStartTime" -Value (Get-Date) -Force
    #Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "PauseFeatureUpdatesEndTime" -Value $PauseEndDate -Force

    #Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "PauseQualityUpdatesStartTime" -Value (Get-Date) -Force
    #Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "PauseQualityUpdatesEndTime" -Value $PauseEndDate -Force
    
    #[System.Windows.Forms.MessageBox]::Show("Automatic updates have been paused for $Days days until $PauseEndDate.")
    Write-Host "Automatic updates have been paused for $Days days until $PauseEndDate."
}


function f1{
    Write-Host "f1"
}

function f2{
    Write-Host "f2"
}

function Install-Chrome{
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

    } catch [System.Net.WebException] {
        Write-Error "Network error occurred while downloading the installer: $_. Exception message: $($_.Exception.Message)"
        Add-Content -Path $LogFile -Value "Network error: $($_.Exception.Message)"
    } catch [System.Exception] {
        Write-Error "An error occurred during the installation: $_. Exception message: $($_.Exception.Message)"
        Add-Content -Path $LogFile -Value "Installation error: $($_.Exception.Message)"
    } finally {
        # Ensure cleanup even if there was an error
        if (Test-Path "$Path\$Installer") {
            Remove-Item -Path "$Path\$Installer" -Force -ErrorAction SilentlyContinue
        }
    }
}


function f5{
    Write-Host "f5"
}
function f6{
    Write-Host "f6"
}







# Show the form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
