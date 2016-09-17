FactoryGirl.define do
  factory :affiliation_citizens, class: Affiliation::Citizens do
    name 'Citizens'
    initialize_with { Affiliation::Citizens.find_or_create_by_id(Affiliation::CITIZENS)}
  end

end