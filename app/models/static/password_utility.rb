class Static::PasswordUtility

  def self.generate_hashed_password(password, salt)
    salted_password = password + (salt || '')
    salted_password_hashed = (Digest::SHA2.new << salted_password).to_s
    salted_password_hashed
  end

  def self.check_password(password, salt, hashed_password)
    generated_hashed_password = self.generate_hashed_password(password, salt)
    generated_hashed_password == hashed_password
  end

end