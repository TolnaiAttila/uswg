function toggleTextboxes() {
    var textboxes = document.querySelectorAll('.hidden-textbox');
    var submitButton = document.getElementById('submit-button');

    textboxes.forEach(function(textbox) {
        textbox.style.display = 'block';
    });
    submitButton.style.display = 'block';
}

document.addEventListener('DOMContentLoaded', function () {
    var buttons = document.querySelectorAll('.add-passwd-user-button');

    buttons.forEach(function (button) {
        button.addEventListener('click', function () {
            var buttonValue = this.value;

            var hiddenInput = document.getElementById('hidden-input-user');
            hiddenInput.value = buttonValue;
            document.getElementById('displayElement').innerText = "Kiválasztott felhasználó: " + buttonValue;
        });
    });
});