# Load assembly for windows forms
Add-Type -AssemblyName System.Windows.Forms

# Create a new Form as an input box
$CommitForm = New-Object System.Windows.Forms.Form
$CommitForm.width = 300
$CommitForm.height = 150
$CommitForm.Text = "Commit Message"

# Create a label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Enter your commit message:"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(10,10) 
$CommitForm.Controls.Add($label)

# Create a text box for input
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,30)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$CommitForm.Controls.Add($textBox)

# Create a button for submitting
$button = New-Object System.Windows.Forms.Button
$button.Text = "OK"
$button.DialogResult = [System.Windows.Forms.DialogResult]::OK
$button.Location = New-Object System.Drawing.Point(180,60)
$CommitForm.AcceptButton = $button
$CommitForm.Controls.Add($button)

# Show the form and store the outcome
$result = $CommitForm.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    git pull
    git add .
    git commit -m "$textBox.Text"
    git push
}
else
{
    Write-Host "Commit cancelled."
}