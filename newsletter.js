/* The Patch — Newsletter Form Handler */

(function () {
  const style = document.createElement('style');
  style.textContent = `
    .newsletter-success {
      display: flex;
      align-items: center;
      gap: 14px;
      background: rgba(62,207,107,0.1);
      border: 1px solid rgba(62,207,107,0.35);
      border-radius: 10px;
      padding: 18px 22px;
      max-width: 500px;
      margin: 0 auto;
      animation: fadeIn 0.3s ease;
    }
    .success-check { font-size: 22px; color: #3ecf6b; flex-shrink: 0; }
    .newsletter-success p { font-size: 15px; color: #e8e8f0; line-height: 1.5; margin: 0; }
    .newsletter-form input.input-error { border-color: #e84057 !important; outline: none; }
    .newsletter-form .field-error { font-size: 12px; color: #e84057; margin-top: 6px; text-align: center; display: block; }
    .newsletter-form button:disabled { opacity: 0.6; cursor: not-allowed; }
    @keyframes fadeIn { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }
  `;
  document.head.appendChild(style);

  function handleForm(form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var input = form.querySelector('input[type="email"]');
      var btn   = form.querySelector('button[type="submit"]');
      var email = (input.value || '').trim();
      var container = form.closest('#beehiiv-embed-placeholder') || form.parentElement;

      input.classList.remove('input-error');
      var prev = form.querySelector('.field-error');
      if (prev) prev.remove();

      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        input.classList.add('input-error');
        var err = document.createElement('span');
        err.className = 'field-error';
        err.textContent = 'Please enter a valid email address.';
        form.appendChild(err);
        input.focus();
        return;
      }

      btn.textContent = '\u2026';
      btn.disabled = true;
      input.disabled = true;

      setTimeout(function () {
        container.innerHTML =
          '<div class="newsletter-success">' +
          '<span class="success-check">\u2713</span>' +
          '<p>You\u2019re on the list! We\u2019ll send you the patch analysis within 1 hour of the next update.</p>' +
          '</div>';
      }, 500);
    });
  }

  function init() {
    document.querySelectorAll('.newsletter-form').forEach(handleForm);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
