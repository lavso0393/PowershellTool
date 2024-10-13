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
$checkboxes = @()

# Function to create and add checkboxes to the form
function Add-Checkbox {
    param ($text, $x, $y)
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $text
    $checkbox.Location = New-Object System.Drawing.Point($x, $y)
    $checkbox.Size = New-Object System.Drawing.Size(250,20)
    $checkbox.Checked = $true  # Pre-check the checkbox
    $form.Controls.Add($checkbox)
    $checkboxes += $checkbox
}

# Add checkboxes for various tasks (pre-checked by default)
Add-Checkbox "Uninstall Office" 20 110
Add-Checkbox "Install Office" 20 140
Add-Checkbox "Install Chrome" 20 170
Add-Checkbox "Disable automatic updates" 20 200
Add-Checkbox "Install EY Templates" 20 230
Add-Checkbox "Install EY Fonts" 20 260

#debuging
Write-Host $checkboxes

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
    foreach ($checkbox in $checkboxes) {
        if ($checkbox.Checked) {
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

    # Show the message box
    [System.Windows.Forms.MessageBox]::Show($message)
    $form.Close()
})

# Show the form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
