class Dia < ActiveRecord::Base
  attr_accessible :entrada, :intervalo, :mes_id, :numero, :saida, :usuario_id, :intervalo_time

  belongs_to :usuario
  belongs_to :mes
  has_many :atividades, :dependent => :destroy

  accepts_nested_attributes_for :atividades

  attr_accessible :atividades_attributes

  validates :numero, :uniqueness => {:scope => :mes_id}
  validates :mes_id, :presence => true
  validates :usuario_id, :presence => true
  validate :validar_horas

  def intervalo_time
    Time.new(2000,1,1,0,0,0,0) + intervalo
  end

  def minutos
    ((saida - entrada) - intervalo) / 60
  end

  def formata_horas
    hora = (((saida - entrada) - intervalo) / 3600).to_i
    minuto = ((((saida - entrada) - intervalo) % 3600) / 60).to_i
    hora.to_s.rjust(2, '0') + ":" + minuto.to_s.rjust(2, '0')
  end

  def formata_intervalo
    hora = (intervalo / 3600).to_i
    minuto = (( intervalo % 3600) / 60).to_i
    hora.to_s.rjust(2, '0') + ":" + minuto.to_s.rjust(2, '0')
  end

  def bar_width
    width = minutos.nil? ? "0" : (minutos/60 * 8).to_s
    width + "%"
  end

  def horas_atividades_formato
    total_horas_atividade = 0
    total_minutos_atividade = 0

    self.atividades.each do |atividade|
      if atividade.aprovacao
        total_minutos_atividade = total_minutos_atividade + (atividade.minutos.nil? ? 0 : (atividade.minutos))
      end
    end
      hh, mm = (total_minutos_atividade).divmod(60)
      ("%02d"%hh).to_s+":"+("%02d"%mm.to_i).to_s
  end

  def horas_atividades
    retorno = 0
    self.atividades.each do |atividade|

      if atividade.aprovacao
        retorno = retorno + (atividade.horas.nil? ? 0 : atividade.horas.to_i)
      end
    end
    retorno/3600
  end

  private
    def validar_horas
      if( saida - entrada - intervalo) <= 0
        errors.add(:atividade, "Day has unvalid time")
      end
    end

end
