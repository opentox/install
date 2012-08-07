# local development installation

$compound = { :uri => "http://webservices.in-silico.ch/compound" }

$algorithm = { :uri => "http://localhost:8081/algorithm" }
#$compound = { :uri => "http://localhost:8082/compound" }
$dataset = { :uri => "http://localhost:8083/dataset" }
$feature  = { :uri => "http://localhost:8084/feature" }
#$model  = { :uri => "http://localhost:8085/model" }
$task  = { :uri => "http://localhost:8086/task" }
#$validation  = { :uri => "http://localhost:8087/validation" }

$four_store = {
  :uri => 'http://localhost:8088',
  :user => '',
  :password => ''
}

$aa = {
  :uri => '' #'https://opensso.in-silico.ch',
  #:user => 'guest',
  #:password => 'guest',
  #:free_request => [:HEAD],
  #:authenticate_request => [],
  #:authorize_request => [:GET, :POST, :DELETE, :PUT],
  #:authorize_exceptions => {[:GET, :POST, :HEAD] => [$task[:uri],$feature[:uri],$dataset[:uri]]}
}
