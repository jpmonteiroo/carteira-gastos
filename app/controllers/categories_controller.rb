class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: %i[edit update destroy]

  def index
    @selected_kind = params[:kind].presence_in(Category::KINDS)
    @categories = ::Categories::IndexQuery.new(
      user: current_user,
      filters: { kind: @selected_kind }
    ).call
    @categories_count = @categories.size
    @active_filters = build_active_filters
  end

  def new
    @category = build_category
  end

  def create
    @category = build_category(category_params)

    if @category.save
      redirect_to categories_path, notice: "Categoria criada com sucesso."
    else
      render_form(:new)
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "Categoria atualizada com sucesso."
    else
      render_form(:edit)
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: "Categoria removida com sucesso."
  end

  private

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :kind, :color)
  end

  def build_category(attributes = {})
    current_user.categories.new(attributes)
  end

  def render_form(view)
    render view, status: :unprocessable_content
  end

  def build_active_filters
    [].tap do |filters|
      next unless @selected_kind.present?

      filters << "Tipo: #{view_context.category_kind_label(@selected_kind)}"
    end
  end
end
