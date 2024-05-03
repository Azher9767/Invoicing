RSpec.describe FormPresenter do
  let(:template) { ActionController::Base.new.view_context }
  let(:category) { build(:category, name: "") }

  subject(:presenter) do
    described_class.new(category, template, 'form-control')
  end
  
  context "without erors" do
    it 'without validations error default class' do
      html_msg = presenter.input_field_options(:name)
      expected_message = { class: 'form-control' }
      expect(html_msg).to eq(expected_message)
    end

    it 'should add default & extra class' do
      html_msg = presenter.input_field_options(:name, 'extra class')
      expected_msg = { class: 'form-control extra class' }
      expect(html_msg).to eq(expected_msg)
    end
  end

  context 'form render with validation errors' do
    before do
      category.valid?
    end

    it 'add error classes with aria' do
      html_msg = presenter.input_field_options(:name)
      expected_msg = { aria: { describedby: 'name_aria'}, class: 'form-control  is-invalid' }
      expect(html_msg).to eq(expected_msg)
    end

    it 'error container with error message' do
      html_msg = presenter.error_container_for(:name)
      expected_msg = "<div class=\"invalid-feedback\" id=\"name_aria\">can't be blank</div>"
      expect(html_msg).to eq(expected_msg)
    end
  end
end
