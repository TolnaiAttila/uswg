document.addEventListener('DOMContentLoaded', function () {
    var form = document.getElementById('installdhcpForm');
    var toggleButton = document.getElementById('installdhcpButton');

    toggleButton.addEventListener('click', function () {
        form.classList.toggle('hidden');
    });
});

document.addEventListener('DOMContentLoaded', function () {
    var form = document.getElementById('addnewsubnetForm');
    var toggleButton = document.getElementById('addnewsubnetButton');

    toggleButton.addEventListener('click', function () {
        form.classList.toggle('hidden');
    });
});


document.addEventListener('DOMContentLoaded', function () {
    var form = document.getElementById('addnewstatichostForm');
    var toggleButton = document.getElementById('addnewstatichostButton');

    toggleButton.addEventListener('click', function () {
    form.classList.toggle('hidden');
        });
});
