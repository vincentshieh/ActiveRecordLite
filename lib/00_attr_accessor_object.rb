class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) { instance_variable_get("@#{name}") }
      setter_method_name = (name.to_s + "=").to_sym
      define_method(setter_method_name) do |val|
        instance_variable_set("@#{name}", val)
      end
    end
  end
end
