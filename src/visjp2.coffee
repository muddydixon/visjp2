$ ()->
  cost = d3.random.normal(100, 10)
  performance = d3.random.normal(120, 30)
  data = d3.range(0, 8).map (d)-> {id: d, date: new Date(2013, 0, d), cost: cost(), performance: performance(), term: 0|Math.random() * 5 + 1}
  data.forEach (d)-> d.ratio = d.performance / d.cost

  width = $(window).width() - 100
  height = 0| ($(window).height() - 200) / 3

  ############################################################
  #
  # radios
  #
  do (base = $('#radios'))->
    cellWidth  = cellHeight = height - 100
    color = d3.scale.category20()
    cRadius = d3.scale.linear().domain(d3.extent(data, (d)-> d.cost)).range([5, cellWidth / 5])
    pRaduis = cellWidth - 30
    ratio = d3.scale.linear().domain(d3.extent(data, (d)-> d.ratio)).range([0, Math.PI / 4]).clamp(true)
    
    svg = d3.select(base.get(0)).append('svg').attr('width', width).attr('height', height)
      .append('g').attr('width', width).attr('height', height)
      .attr('transform', "translate(30, 0)")

    
    radio = svg.selectAll('g.radio').data(data).enter().append('g').attr('class', 'radio')
      .attr('width'. cellWidth).attr('height', cellHeight).attr('transform', (d, idx)-> "translate(#{(cellWidth + 50) * idx}, 0)")

    radio.append('circle').attr('cx', 0).attr('cy', cellHeight / 2).attr('r', (d)-> cRadius(d.cost))
      .attr('fill', (d)-> color(d.id))

    radio.append('g').attr('transform', "translate(0,#{cellHeight / 2})")
      .append('path').attr('d', (d)->
        d3.svg.arc().innerRadius(0).outerRadius(pRaduis)({startAngle: Math.PI / 2 * (1 - ratio(d.ratio)), endAngle: Math.PI / 2 * (1 + ratio(d.ratio))}))
      .attr('fill', (d)-> color(d.id)).style('opacity', .1)
    radio.append('g').attr('transform', "translate(0,#{cellHeight / 2})")
      .selectAll('path.arc').data((d)->[1..d.term].map (i)-> {id: d.id, r: pRaduis / d.term * i, deg: d.ratio}).enter()
      .append('path').attr('class', 'arc')
      .attr('d', (e)-> d3.svg.arc().innerRadius(e.r - 3).outerRadius(e.r)({startAngle: Math.PI / 2 * (1 - ratio(e.deg)), endAngle: Math.PI / 2 * (1 + ratio(e.deg))}))
      .attr('fill', (d)-> color(d.id))

  ############################################################
  #
  # arrows
  #
  do (base = $('#arrows'))->
    cellWidth  = cellHeight = height - 100

    cost = d3.scale.linear().domain(d3.extent(data, (d)-> d.cost)).range([5, 20]) # size of arrow
    
    deg = d3.scale.linear().domain(d3.extent(data, (d)-> d.ratio)).range([45, -45])
    color = d3.scale.linear().domain(d3.extent(data, (d)-> d.ratio)).range(['blue', 'red'])
    
    svg = d3.select(base.get(0)).append('svg').attr('width', width).attr('height', height)
      .append('g').attr('width', width).attr('height', height)
      .attr('transform', "translate(30, 0)")

    arrow = svg.selectAll('g.arrow').data(data).enter().append('g').attr('class', 'arrow')
      .attr('width'. cellWidth).attr('height', cellHeight).attr('transform', (d, idx)-> "translate(#{(cellWidth + 50) * idx}, #{cellHeight / 2})")

    arr = (d)-> c = cost(d.cost); "M0,#{c}L20,#{c}L20,#{c + 5}L25,0L20,-#{c + 5}L20,-#{c}L0,-#{c}"
    arrow.append('path').attr('d', arr).attr('fill', (d)-> color(d.ratio))
      .attr('transform', (d)-> "rotate(#{deg(d.ratio)})")

  ############################################################
  #
  # opamps
  #
  do (base = $('#opamps'))->
    cellWidth  = cellHeight = height - 100
    color = d3.scale.category20()

    # cHeight = d3.scale.linear().domain(d3.extent(data, (d)-> d.cost)).range([10, 30])
    # pHeight = d3.scale.linear().domain(d3.extent(data, (d)-> d.performance)).range([10, 30])
    h = d3.scale.linear().domain(d3.extent(data.map((d)-> d.cost)).concat(data.map((d)-> d.performance))).range([10, 30])

    
    svg = d3.select(base.get(0)).append('svg').attr('width', width).attr('height', height)
      .append('g').attr('width', width).attr('height', height)
      .attr('transform', "translate(30, 0)")

    opamp = svg.selectAll('g.arrow').data(data).enter().append('g').attr('class', 'arrow')
      .attr('width'. cellWidth).attr('height', cellHeight).attr('transform', (d, idx)-> "translate(#{(cellWidth + 50) * idx}, 0)")

    input = opamp.append('rect').attr('class', 'input')
      .attr('width', 20).attr('height', (d)-> h(d.cost))
      .attr('x', 0).attr('y', (d)-> - h(d.cost) / 2 + 50)
      .attr('fill', (d)-> color(d.id))
    # output = opamp.append('rect').attr('class', 'output')
    #   .attr('width', 20).attr('height', (d)-> h(d.performance))
    #   .attr('x', 80).attr('y', (d)-> - h(d.performance) / 2 + 50)
    #   .attr('fill', (d)-> color(d.id))
    output = opamp.append('path').attr('class', 'output')
      .attr('d', (d)->
        _h = h(d.performance) / 2
        "M80,#{50 - _h}L100,#{50 - _h}L100,#{50 - _h - 10}L120,50L100,#{50 + _h + 10}L100,#{50 + _h}L80,#{50 + _h}"
      )
      .attr('fill', (d)-> color(d.id))
      
    label = opamp.append('rect').attr('class', 'label')
      .attr('x', 20).attr('y', 0)
      .attr('width', 60).attr('height', 100)
      .attr('rx', 5).attr('ry', 5)
      .attr('stroke', 'black').attr('fill', 'white')
    ratio = opamp.append('text').text((d)-> d.ratio.toFixed(2)).style('font-size', '18pt').attr('fill', '#666').attr('dx', 20).attr('dy', 60)
    
    