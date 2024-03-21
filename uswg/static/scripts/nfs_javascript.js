document.addEventListener('DOMContentLoaded', function () {
    var form = document.getElementById('createnfsshareForm');
    var toggleButton = document.getElementById('addnewshareButton');

    toggleButton.addEventListener('click', function () {
    form.classList.toggle('hidden');
        });
});

document.addEventListener('DOMContentLoaded', function () {
    var form = document.getElementById('createnfsaccessForm');
    var toggleButton = document.getElementById('addnewaccessButton');

    toggleButton.addEventListener('click', function () {
    form.classList.toggle('hidden');
        });
});