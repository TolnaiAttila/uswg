document.addEventListener('DOMContentLoaded', function () {
    var form = document.getElementById('allowadapterForm');
    var toggleButton = document.getElementById('allowadapterButton');

    toggleButton.addEventListener('click', function () {
        form.classList.toggle('hidden');
    });
});