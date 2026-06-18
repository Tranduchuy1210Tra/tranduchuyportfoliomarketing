function toggleAcc(btn) {
  const body = btn.nextElementSibling;
  const isOpen = body.classList.contains('open');
  // Close all
  document.querySelectorAll('.acc-body').forEach(b => b.classList.remove('open'));
  document.querySelectorAll('.acc-btn').forEach(b => b.classList.remove('active'));
  // Open clicked if it was closed
  if (!isOpen) {
    body.classList.add('open');
    btn.classList.add('active');
    setTimeout(() => btn.scrollIntoView({behavior:'smooth', block:'nearest'}), 50);
  }
}

function openLB(src) {
  document.getElementById('lb-img').src = src;
  document.getElementById('lb').classList.add('open');
  document.body.style.overflow = 'hidden';
}
function closeLB() {
  document.getElementById('lb').classList.remove('open');
  document.body.style.overflow = '';
}
document.addEventListener('keydown', e => { if(e.key==='Escape') closeLB(); });

// Open first accordion by default
document.querySelector('.acc-btn').click();
