class Usuario < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :nome, :horario_mensal
  attr_accessible :valor_da_hora, :entrada_usp, :saida_usp, :cpf, :banco, :conta, :agencia
  attr_accessible :role, :address, :cel, :valor_da_bolsa_fau, :horas_da_bolsa_fau, :funcao
  attr_accessible :data_admissao_fau, :data_demissao_fau

  attr_accessor :ddd, :tel_numero

  validates :nome, :presence => true,
                   :uniqueness => true

  validates :tel_numero, :length => {:minimum => 7, :maximum => 10}

  has_many :banco_de_horas
  has_many :mes
  has_many :dias
  has_many :atividades



  def ddd=
    raise "passou!"
  end


end
