require 'open-uri'
require 'json'

puts "---------------------------"

puts "El torneo consiste en batallas entre el equipo Rocket contra el equipo Ash"
puts "En cada batalla se enfrentan dos pokemon aleatoreos, uno de cada equipo"
puts "El equipo que gana es el que elimina todos los pokemons del equipo rival"
puts "---------------------------"


# funcion para traer la informacion de 4 pokemons aleatorios
def madeTeam
  team = []
  4.times do
    num = rand(1..151)
    url = 'http://pokeapi.co/api/v2/pokemon/' + num.to_s
    response = URI.open(url).read
    json = JSON.parse(response)
    team.push(json)
  end
  return team
end

#arreglo donde se guardan los equipos con sus 4 pokemons
$teams = [
  { "name": 'Rocket', "pokemons": madeTeam },
  { "name": 'Ash', "pokemons": madeTeam }
]

#aqui se muestran en pantalla los pokemons de cada equipo
puts "Pokemons equipo ROCKET:"
$teams[0][:pokemons].each do |pokemon|
  puts pokemon["name"]
end
puts " "
puts "Pokemons equipo Ash:"
$teams[1][:pokemons].each do |pokemon|
  puts pokemon["name"]
end
puts " "
  
puts "---------------------------"
puts 'EL TORNEO COMIENZA AQUI!'
puts " "

#contador del numero de batallas
$battleNum = 1 

def battle(rocketPokemon, ashPokemon)
  
  puts "BATALLA NUMERO #{$battleNum}" + $battleNum.to_s

  rocketStats = 0    #acumula la suma de todas las base_stat
  ashStats = 0   #acumula la suma de todas las base_stat

  rocketX = 1   #multiplicador de daño equipo rocket
  ashX = 1      #multiplicador de daño equipo ash

  #doble ciclo para recorrer cada type de ambos pokemons
  rocketPokemon['types'].each do |rocketType|
    ashPokemon['types'].each do |ashType|
      typeUrl = ashType['type']['url']
      response = URI.open(typeUrl).read
      json = JSON.parse(response)

      #ahora se revisan los tipos del pokemon del equipo Ash
      # y se revisa su reaccion a los otros tipos de pokemon
      # obtenidos del json de la nueva consulta

      #ahora se compara cada tipo del equipo Ash con el del equipo Rocket

      #se multiplica por dos a la variable de equipo Rocket
      json['damage_relations']['double_damage_from'].each do |damageFrom|
        rocketX *= 2 if damageFrom['name'] == rocketType['type']['name']
      end

      #se multiplica por 1.5 a la variable de equipo Rocket
      json['damage_relations']['half_damage_from'].each do |damageFrom|
        rocketX *= 0.5 if damageFrom['name'] == rocketType['type']['name']
      end

      #se multiplica por cero a la variable de equipo Rocket
      json['damage_relations']['no_damage_from'].each do |damageFrom|
        rocketX *= 0 if damageFrom['name'] == rocketType['type']['name']
      end

      #se multiplica por dos a la variable de equipo Ash
      json['damage_relations']['double_damage_to'].each do |damageFrom|
        ashX *= 2 if damageFrom['name'] == rocketType['type']['name']
      end

      #se multiplica por 1.5 a la variable de equipo Ash
      json['damage_relations']['half_damage_to'].each do |damageFrom|
        ashX *= 0.5 if damageFrom['name'] == rocketType['type']['name']
      end

      #se multiplica por cero a la variable de equipo Ash
      json['damage_relations']['no_damage_to'].each do |damageFrom|
        ashX *= 0 if damageFrom['name'] == rocketType['type']['name']
      end
    end
  end

  #se suman todas las stats del equipo Rocket
  rocketPokemon['stats'].each do |stat|
    rocketStats += stat['base_stat']
  end

  #se suman todas las stats del equipo Ash
  ashPokemon['stats'].each do |stat|
    ashStats += stat['base_stat']
  end

  #Se multiplica cada Stats por su multiplicador resultante
  ashStats *= ashX
  rocketStats *= rocketX

  puts "#{rocketPokemon['name']} - #{rocketStats} stats (equipo Rocket) VS #{ashPokemon['name']} #{ashStats} stats (equipo Ash)"

  if ashStats > rocketStats
    $teams[0][:pokemons].delete (rocketPokemon)
    puts "Ganador de esta batalla: pokemón #{ashPokemon['name']} del equipo Ash"
  elsif
    $teams[1][:pokemons].delete (ashPokemon)
    puts "Ganador de esta batalla: pokemón #{rocketPokemon['name']} del equipo Rocket"
  end

  $battleNum += 1
  puts "  "
    
end

#Se realiza la batalla mientras existan pokemones dentro del equipo
#Si alguno de los dos equipos contiene el array vacío, no se ejecuta
while $teams[0][:pokemons].empty? == false && $teams[1][:pokemons].empty? == false
  battle($teams[0][:pokemons].sample, $teams[1][:pokemons].sample)
end
puts "---------------------------"
puts "FIN DEL TORNEO"
puts " "

#El ganador es el que no tiene el array vacío
if $teams[0][:pokemons].empty? == false 
  puts "El ganador es el equipo Rocket con #{$teams[0][:pokemons].length} pokemons restantes: "
  $teams[0][:pokemons].each do |pokemon|
    puts "- #{pokemon["name"]}"
  end
elsif $teams[1][:pokemons].empty? == false
  puts "El ganador es el equipo Ash con #{$teams[1][:pokemons].length} pokemons restantes: "
  $teams[1][:pokemons].each do |pokemon|
    puts "- #{pokemon["name"]}"
  end
end

puts "---------------------------"