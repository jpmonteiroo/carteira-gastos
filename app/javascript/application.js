// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

const transactionKinds = ["income", "expense"];
let modalEventsInitialized = false;

function buildCategoryOption(category) {
  const option = document.createElement("option");
  option.value = category.id;
  option.textContent = category.name;
  return option;
}

function buildPromptOption(prompt) {
  const option = document.createElement("option");
  option.value = "";
  option.textContent = prompt;
  return option;
}

function refreshTransactionCategories(form) {
  const typeSelect = form.querySelector('[data-role="transaction-type"]');
  const categorySelect = form.querySelector('[data-role="category-select"]');
  const submitButton = form.querySelector('[data-role="submit-button"]');
  const emptyState = form.querySelector('[data-role="empty-state"]');
  const emptyStateKind = form.querySelector('[data-role="empty-state-kind"]');

  if (!typeSelect || !categorySelect || !submitButton || !emptyState || !emptyStateKind) return;

  const selectedType = transactionKinds.includes(typeSelect.value) ? typeSelect.value : "";
  const selectedCategoryId = categorySelect.value;
  const prompt = categorySelect.dataset.prompt || "Selecione uma categoria";
  const allCategories = JSON.parse(categorySelect.dataset.options || "[]");
  const visibleCategories = selectedType ? allCategories.filter((category) => category.kind === selectedType) : allCategories;

  categorySelect.replaceChildren(buildPromptOption(prompt));
  visibleCategories.forEach((category) => {
    categorySelect.appendChild(buildCategoryOption(category));
  });

  const categoryStillAvailable = visibleCategories.some((category) => String(category.id) === selectedCategoryId);
  categorySelect.value = categoryStillAvailable ? selectedCategoryId : "";

  const hasCategories = visibleCategories.length > 0;
  categorySelect.disabled = !hasCategories;
  submitButton.disabled = !hasCategories;
  emptyState.classList.toggle("hidden", hasCategories);

  if (selectedType === "income") {
    emptyStateKind.textContent = form.dataset.categoryLabelIncome || "receita";
  } else {
    emptyStateKind.textContent = form.dataset.categoryLabelExpense || "despesa";
  }
}

function initializeTransactionForms() {
  document.querySelectorAll('form[data-transaction-form="true"]').forEach((form) => {
    if (form.dataset.transactionFormInitialized === "true") return;

    const typeSelect = form.querySelector('[data-role="transaction-type"]');
    if (!typeSelect) return;

    typeSelect.addEventListener("change", () => refreshTransactionCategories(form));
    form.dataset.transactionFormInitialized = "true";
    refreshTransactionCategories(form);
  });
}

function closeModal(modal) {
  if (!modal) return;

  modal.classList.add("hidden");

  if (!document.querySelector("[data-modal]:not(.hidden)")) {
    document.body.classList.remove("overflow-hidden");
  }
}

function openModal(modal) {
  if (!modal) return;

  modal.classList.remove("hidden");
  document.body.classList.add("overflow-hidden");
}

function initializeModalEvents() {
  if (modalEventsInitialized) return;

  document.addEventListener("click", (event) => {
    const openTrigger = event.target.closest("[data-modal-open]");

    if (openTrigger) {
      openModal(document.getElementById(openTrigger.dataset.modalOpen));
      return;
    }

    const closeTrigger = event.target.closest("[data-modal-close]");

    if (closeTrigger) {
      closeModal(closeTrigger.closest("[data-modal]"));
    }
  });

  document.addEventListener("keydown", (event) => {
    if (event.key !== "Escape") return;

    document.querySelectorAll("[data-modal]:not(.hidden)").forEach((modal) => closeModal(modal));
  });

  modalEventsInitialized = true;
}

initializeModalEvents();
document.addEventListener("turbo:load", initializeTransactionForms);
document.addEventListener("DOMContentLoaded", initializeTransactionForms);
