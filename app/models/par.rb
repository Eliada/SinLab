class Par < ActiveRecord::Base
  belongs_to :par, :class_name => "Usuario"
  validates_uniqueness_of :par_id, :scope => :atividade_id

  def minutos
    duracao.blank? ? 0 : duracao/60
  end

  def minutos=(minutos)
    self.duracao = minutos.to_i * 60
  end
end
