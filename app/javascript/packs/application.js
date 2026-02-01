import 'bootstrap'
import 'bootstrap/dist/css/bootstrap.min.css'

document.addEventListener('DOMContentLoaded', function() {
  const loadMoreBtn = document.getElementById('load-more-btn');
  const matchesContainer = document.getElementById('matches-container');
  const loadingSpinner = document.getElementById('loading-spinner');
  
  if (loadMoreBtn) {
    loadMoreBtn.addEventListener('click', function() {
      const puuid = this.dataset.puuid;
      const offset = parseInt(this.dataset.offset);
      
      // Mostra loading
      loadMoreBtn.style.display = 'none';
      loadingSpinner.style.display = 'block';
      
      // Faz requisição AJAX
      fetch(`/load_more_matches?puuid=${puuid}&offset=${offset}`, {
        headers: {
          'Accept': 'text/javascript',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      .then(response => response.text())
      .then(html => {
        // Adiciona as novas partidas
        matchesContainer.insertAdjacentHTML('beforeend', html);
        
        // Atualiza offset para próxima requisição
        loadMoreBtn.dataset.offset = offset + 10;
        
        // Esconde loading e mostra botão novamente
        loadingSpinner.style.display = 'none';
        loadMoreBtn.style.display = 'inline-block';
      })
      .catch(error => {
        console.error('Error loading more matches:', error);
        loadingSpinner.style.display = 'none';
        loadMoreBtn.style.display = 'inline-block';
        alert('Erro ao carregar mais partidas');
      });
    });
  }
});