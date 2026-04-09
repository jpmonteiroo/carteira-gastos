class ApplicationController < ActionController::Base
  before_action :load_financial_notifications, if: :user_signed_in?

  private

  def load_financial_notifications
    @financial_notifications_context = ::Notifications::FinancialVolumeQuery.new(
      user: current_user,
      wallet_id: params[:wallet_id],
      period: params[:period],
      reference_date: params[:reference_date]
    ).call
  end
end
