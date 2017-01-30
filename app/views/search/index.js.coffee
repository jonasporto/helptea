# actually, we don't have any articles at all
results = $('.results')
setTimeout (-> 
  results.addClass('active').html('No articles found')
  setTimeout (-> results.removeClass('active')), 10000
), 1000