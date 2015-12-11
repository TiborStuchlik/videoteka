class Movies < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = "Import"
  end

  #include PgGridTweaks
end