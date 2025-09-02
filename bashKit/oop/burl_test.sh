#!/usr/bin/env bash

burlLiveTest() {
  #
  # Test
  objectInstanceNew burl aeon
  echo ""
  echo "================================="
  echo ":: TEST _ DEFAULT VALUES"
  burl aeon exec setURL ""
  echo -ne "        headers : "; burl aeon exec printHeaders
  echo -ne "           verb : "; burl aeon get verb
  echo -ne "       protocol : "; burl aeon get protocol
  echo -ne "protocolVersion : "; burl aeon get protocolVersion
  echo -ne "         domain : "; burl aeon get domain
  echo -ne "           port : "; burl aeon get port
  echo -ne "           path : "; burl aeon get path
  echo -ne "   querystrings : "; burl aeon exec printQuerystrings
  echo -ne "       fragment : "; burl aeon get fragment



  echo ""
  echo "================="
  echo ":: TEST _ HEADERS"
  burl aeon set header set "Connection" "close"
  burl aeon set header set "Host" "domain.com"
  echo -ne "        headers : "; burl aeon exec printHeaders
  echo -ne "    header Host : "; burl aeon get header "Host"
  burl aeon set header clear
  echo -ne "        headers : "; burl aeon exec printHeaders



  echo ""
  echo "================="
  echo ":: TEST _ SET GET"
  burl aeon set verb gete # must fail
  burl aeon set verb get

  echo -ne "           verb : "; burl aeon get verb
  echo -ne "       protocol : "; burl aeon get protocol
  echo -ne "protocolVersion : "; burl aeon get protocolVersion
  echo ""



  burl aeon set domain ^aeondigital.com # must fail
  burl aeon set domain aeondigital.com
  echo -ne "         domain : "; burl aeon get domain
  echo ""



  burl aeon set port a8080 # must fail
  burl aeon set port 8080
  echo -ne "           port : "; burl aeon get port
  echo ""



  burl aeon set path "invalid-path-with-invalid-#-chars" # must fail
  burl aeon set path "//valid-path/with/many/parts///"
  echo -ne "           path : "; burl aeon get path
  echo ""



  burl aeon set querystring set "in^valid" "val01" # must fail
  burl aeon set querystring set "qs1" "val01"
  burl aeon set querystring set "qs2" "val02"
  echo -ne "querystring qs1 : "; burl aeon get querystring qs1
  echo -ne "querystring qs2 : "; burl aeon get querystring qs2
  echo -ne "querystring qs3 : "; burl aeon get querystring qs3
  burl aeon exec printQuerystrings
  echo ""



  burl aeon set fragment section-3
  echo -ne "       fragment : "; burl aeon get fragment
  echo ""



  echo ""
  echo "================================="
  echo ":: TEST _ RESET TO DEFAULT VALUES"
  burl aeon exec setURL ""
  burl aeon set header clear
  echo -ne "        headers : "; burl aeon exec printHeaders
  echo -ne "           verb : "; burl aeon get verb
  echo -ne "       protocol : "; burl aeon get protocol
  echo -ne "protocolVersion : "; burl aeon get protocolVersion
  echo -ne "         domain : "; burl aeon get domain
  echo -ne "           port : "; burl aeon get port
  echo -ne "           path : "; burl aeon get path
  echo -ne "   querystrings : "; burl aeon exec printQuerystrings
  echo -ne "       fragment : "; burl aeon get fragment
  echo ""



  echo ""
  echo "================================="
  echo ":: TEST _ RESET NEW URL"
  burl aeon exec setURL "PUT https://www.aeondigital.com.br:8888/caminho/valido/até/página.php?qst=vv1&qst2=vv2&qst3=vv3#part1-1"
  echo -ne "        headers : "; burl aeon exec printHeaders
  echo -ne "           verb : "; burl aeon get verb
  echo -ne "       protocol : "; burl aeon get protocol
  echo -ne "protocolVersion : "; burl aeon get protocolVersion
  echo -ne "         domain : "; burl aeon get domain
  echo -ne "           port : "; burl aeon get port
  echo -ne "           path : "; burl aeon get path
  echo -ne "   querystrings : "; burl aeon exec printQuerystrings
  echo -ne "       fragment : "; burl aeon get fragment
  echo -ne "            url : "; burl aeon exec printURL
  echo ""



  echo ""
  echo "================================="
  echo ":: TEST _ PERFORM REQUEST"
  local -gA requestResponseAssoc
  burl aeon exec request "http://aeondigital.com.br" "file" "respTeste"

  echo ""
  echo "================================="
  echo ":: TEST _ POS REQUEST"
  echo -ne "        headers : "; burl aeon exec printHeaders
  echo -ne "           verb : "; burl aeon get verb
  echo -ne "       protocol : "; burl aeon get protocol
  echo -ne "protocolVersion : "; burl aeon get protocolVersion
  echo -ne "         domain : "; burl aeon get domain
  echo -ne "           port : "; burl aeon get port
  echo -ne "           path : "; burl aeon get path
  echo -ne "   querystrings : "; burl aeon exec printQuerystrings
  echo -ne "       fragment : "; burl aeon get fragment
  echo -ne "            url : "; burl aeon exec printURL
  echo ""
}