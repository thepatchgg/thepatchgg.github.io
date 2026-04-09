/* The Patch - Newsletter Form Handler */

(function () {
  const style = document.createElement("style");
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
    .success-check {
      font-size: 22px;
      color: #3ecf6b;
      flex-shrink: 0;
    }
    .newsletter-success p {
      font-size: 15px;
      color: #e8e8f0;
      line-height: 1.5;
      margin: 0;
    }
    .newsletter-form input.input-error {
      border-color: #e84057 !important;
      outline: none;
    }
    .newsletter-form .field-error {
      font-size: 12px;
      color: #e84057;
      margin-top: 6px;
      text-align: center;
      display: block;
    }
    .newsletter-form button:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(6px); }
      to { opacity: 1; transform: translateY(0); }
    }
  `;
  document.head.appendChild(style);

  function dispatchNewsletter(status, locationTag) {
    window.dispatchEvent(new CustomEvent("thepatch:newsletter", {
      detail: {
        status,
        location: locationTag
      }
    }));
  }

  function handleForm(form) {
    form.addEventListener("submit", function (event) {
      event.preventDefault();

      const input = form.querySelector('input[type="email"]');
      const button = form.querySelector('button[type="submit"]');
      const email = (input.value || "").trim();
      const container = form.closest("#beehiiv-embed-placeholder") || form.parentElement;
      const locationTag = form.dataset.newsletterLocation || window.location.pathname;

      input.classList.remove("input-error");
      const previousError = form.querySelector(".field-error");
      if (previousError) {
        previousError.remove();
      }

      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        input.classList.add("input-error");
        const errorNode = document.createElement("span");
        errorNode.className = "field-error";
        errorNode.textContent = "Please enter a valid email address.";
        form.appendChild(errorNode);
        dispatchNewsletter("invalid", locationTag);
        input.focus();
        return;
      }

      dispatchNewsletter("submit", locationTag);

      button.textContent = "...";
      button.disabled = true;
      input.disabled = true;

      setTimeout(function () {
        window.open(
          "https://thepatchgg.substack.com/subscribe?email=" + encodeURIComponent(email),
          "_blank",
          "noopener,noreferrer"
        );

        dispatchNewsletter("success", locationTag);
        container.innerHTML =
          '<div class="newsletter-success">' +
          '<span class="success-check">&#10003;</span>' +
          '<p>Almost done - finish signing up in the Substack tab that just opened.</p>' +
          "</div>";
      }, 500);
    });
  }

  function init() {
    document.querySelectorAll(".newsletter-form").forEach(handleForm);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
