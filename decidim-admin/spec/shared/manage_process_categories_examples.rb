# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "manage process categories examples" do
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.edit_participatory_process_path(participatory_process)
    click_link "Categories"
  end

  it "creates a new category" do
    find(".card-title a.new").click

    within ".new_participatory_process_category" do
      fill_in_i18n(
        :category_name,
        "#name-tabs",
        en: "My category",
        es: "Mi categoría",
        ca: "La meva categoria"
      )
      fill_in_i18n_editor(
        :category_description,
        "#description-tabs",
        en: "Description",
        es: "Descripción",
        ca: "Descripció"
      )

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "#categories table" do
      expect(page).to have_content("My category")
    end
  end

  it "updates a category" do
    within "#categories" do
      within find("tr", text: translated(category.name)) do
        page.find('a.action-icon--edit').click
      end
    end

    within ".edit_participatory_process_category" do
      fill_in_i18n(
        :category_name,
        "#name-tabs",
        en: "My new name",
        es: "Mi nuevo nombre",
        ca: "El meu nou nom"
      )

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "#categories table" do
      expect(page).to have_content("My new name")
    end
  end

  context "deleting a category" do
    let!(:category2) { create(:category, participatory_process: participatory_process) }

    context "when the category has no subcategories" do
      before do
        visit current_path
      end

      it "deletes a category" do
        within find("tr", text: translated(category2.name)) do
          page.find('a.action-icon--remove').click
        end

        within ".callout-wrapper" do
          expect(page).to have_content("successfully")
        end

        within "#categories table" do
          expect(page).not_to have_content(translated(category2.name))
        end
      end
    end

    context "when the category has some subcategories" do
      let!(:subcategory) { create(:subcategory, parent: category2) }

      before do
        visit current_path
      end

      it "deletes a category" do
        within find("tr", text: translated(category2.name)) do
          page.find('a.action-icon--remove').click
        end

        within ".callout-wrapper" do
          expect(page).to have_content("error deleting")
        end

        within "#categories table" do
          expect(page).to have_content(translated(category2.name))
        end
      end
    end
  end
end
