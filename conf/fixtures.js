module.exports = {
  continents: { 
    1:{id:1, area:44.8, name:'Asia'},
    2:{id:2, area:30.3, name:'Africa'},
    3:{id:3, area:24.7, name:'North America'},
    4:{id:4, area:17.8, name:'South America'},
    5:{id:5, area:13.2, name:'Antarctica'},
    6:{id:6, area:10.1, name:'Europe'},
    7:{id:7, area: 8.6, name:'Australia/Oceania'}
  }, // continents
  countries: {
    1:{id:1, continentId:1, area:17.1, name:'Russia'},
    2:{id:2, continentId:3, area:10.0, name:'Canada'},
    3:{id:3, continentId:4, area: 8.5, name:'Brazil'},
    4:{id:4, continentId:7, area: 7.7, name:'Australia'},
    5:{id:5, continentId:2, area: 2.4, name:'Algeria'},
    6:{id:6, continentId:6, area: 0.6, name:'Ukraine'}
  }, // countries
  cities: {
    1:{id:1, countryId:1, population:11.5, name:'Moscow'},
    2:{id:2, countryId:2, population: 1.2, name:'Ottawa'},
    3:{id:3, countryId:3, population: 2.8, name:'Brasília'},
    4:{id:4, countryId:4, population: 0.4, name:'Canberra'},
    5:{id:5, countryId:5, population: 3.5, name:'Algiers'},
    6:{id:6, countryId:6, population: 3.4, name:'Kiev'}
  } // cities
}