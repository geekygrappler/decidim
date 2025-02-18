# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings
  describe CheckCensus do
    subject { described_class.new(form) }

    let(:voting) { create(:voting) }
    let(:datum) { create(:datum, document_numer: document_number, document_type: document_type, birthdate: birthdate, postal_code: postal_code, dataset: dataset) }
    let(:context) { { current_participatory_space: voting } }
    let(:dataset) { create(:dataset, voting: voting) }
    let(:params) do
      {
        document_number: document_number,
        document_type: document_type,
        year: year,
        month: month,
        day: day,
        postal_code: postal_code
      }
    end
    let(:birthdate) { year + month + day }
    let(:document_number) { "123456789Y" }
    let(:document_type) { "DNI" }
    let(:year) { "1985" }
    let(:month) { "03" }
    let(:day) { "01" }
    let(:postal_code) { "12345" }

    let(:form) { CheckCensusForm.from_params(params).with_context(context) }

    context "when the form is not valid" do
      let(:document_number) {}

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end
    end

    context "when census is found" do
      let!(:datum) { create(:datum, document_number: document_number, document_type: document_type, birthdate: birthdate, postal_code: postal_code, dataset: dataset) }

      it "broadcasts ok" do
        expect(subject.call).to broadcast(:ok)
      end
    end

    context "when census is not found" do
      let!(:datum) { create(:datum, document_number: "987654321Y", document_type: document_type, birthdate: birthdate, postal_code: postal_code) }

      it "returns not_found" do
        expect(subject.call).to broadcast(:not_found)
      end
    end

    context "when hashed_checked_data exists in different dataset" do
      let!(:datum) { create(:datum, document_number: "987654321Y", document_type: document_type, birthdate: birthdate, postal_code: postal_code) }
      let!(:voting) { create(:voting) }

      it "returns not_found" do
        expect(subject.call).to broadcast(:not_found)
      end
    end
  end
end
