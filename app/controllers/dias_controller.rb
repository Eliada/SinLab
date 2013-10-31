class DiasController < ApplicationController
  before_filter :authenticate_usuario!

  def new
    @dia = Dia.find_or_create_by_data_and_usuario_id(params[:data], params[:usuario_id])
    @usuario =  @dia.usuario
    @projetos = @usuario.projetos.where("super_projeto_id is not null").order(:nome).collect {|p| [p.nome, p.id ] }
    @projetos_boards = Projeto.all.to_a.each_with_object({}){ |c,h| h[c.id] = c.boards.collect {|c| c.board_id }}.to_json.html_safe
    respond_to do |format|
      format.js
      format.html
    end
  end

  def create
    dia = Dia.find(params[:dia_id])
    dia_success = dia.update_attributes(
      :entrada => convert_date(params[:dia], "entrada"),
      :saida => convert_date(params[:dia], "saida"),
      :intervalo => (params[:dia]["intervalo(4i)"].to_f * 3600.0 +  params[:dia]["intervalo(5i)"].to_f * 60.0),
    )
    atividades_success = true
    params[:dia][:atividades_attributes].each do |lixo, atividade_attr|
      atividade = Atividade.find_by_id atividade_attr[:id].to_i
      if atividade.blank?
        atividade = Atividade.new
      end
      if atividade_attr["_destroy"] == "1" and !atividade.blank?
        atividade.destroy()
      else
        atividades_success = atividades_success and atividade.update_attributes(
          :duracao => atividade_attr["horas"].to_i * 60,
          :observacao => atividade_attr["observacao"],
          :projeto_id => atividade_attr["projeto_id"],
          :dia_id => dia.id,
          :usuario_id => dia.usuario.id,
          :aprovacao => nil,
          :data => dia.data
        )
        unless atividade_attr[:trello].blank?
          atividade_attr[:trello].each_key do |k|
            c = Cartao.where(:atividade_id => atividade.id, :cartao_id => k).last
            if c.blank? and atividade_attr[:trello][k][:check]
              c = Cartao.new(:atividade_id => atividade.id, :cartao_id => k,
                :duracao => atividade_attr[:trello][k][:slider].to_i)
              c.save
            elsif !c.blank? and !atividade_attr[:trello][k][:check]
              c.destroy
            elsif !c.blank? and atividade_attr[:trello][k][:check]
              c.duracao = atividade_attr[:trello][k][:slider]
              c.save
            end
            Cartao.update_on_trello(params[:key], params[:token], k)
          end
        end
      end
    end
    if dia_success and atividades_success
      flash[:notice] = I18n.t("banco_de_horas.create.success")
    else
      flash[:error] = I18n.t("banco_de_horas.create.failure")
    end
    redirect_to dias_path(inicio: dia.data.beginning_of_month.to_formatted_s, fim: dia.data.end_of_month.to_formatted_s, usuario: dia.usuario.id)
  end

  def destroy
    dia = Dia.find params[:id]
    dia.destroy
    redirect_to :back
  end

  def editar_por_data
    dia = Dia.find_by_data_and_usuario_id(params[:data], params[:usuario_id])
    if (!dia.nil?) 
      redirect_to edit_dia_path(dia.id)
    else 
      redirect_to new_dia_path
    end
  end
  
  def index
    @inicio = Date.parse params[:inicio]
    @fim = Date.parse params[:fim]
    @usuario =  Usuario.find_by_id(params[:usuario]) || current_user
    @dias_periodo = dias_no_periodo(@inicio, @fim)
    @dias = Dia.por_periodo(@inicio, @fim, @usuario.id).order(:data)
    @ausencias = Ausencia.por_periodo(@inicio, @fim, @usuario.id)
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def periodos
    @ano = params[:ano] || Date.today.year
    @usuario = params[:usuario] || current_user
    @usuarios = Usuario.order(:nome)
    @periodos = (1..12).collect{|m| {inicio: Date.new(2013, m, 1), fim: Date.new(2013, m, 1).at_end_of_month}}
  end
  
  private

  def convert_date(hash, date_symbol_or_string)
    attribute = date_symbol_or_string.to_s
    return DateTime.new(
      hash[attribute + '(1i)'].to_i,
      hash[attribute + '(2i)'].to_i,
      hash[attribute + '(3i)'].to_i,
      hash[attribute + '(4i)'].to_i,
      hash[attribute + '(5i)'].to_i,
      0 )
  end
end
