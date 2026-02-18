/**
 * Multi-wallet connection for ARCA Presale
 * Supports: MetaMask, Coinbase, Rainbow, Trust, WalletConnect (QR), and all EIP-6963 wallets
 */
import { EthereumProvider } from '@walletconnect/ethereum-provider';
import { WalletConnectModal } from '@walletconnect/modal';
import CoinbaseWalletSDK from '@coinbase/wallet-sdk';

// WalletConnect project ID — get from cloud.reown.com
const WC_PROJECT_ID = window.ARCA_CONFIG?.wcProjectId || ''; // Set in HTML config

const BASE_CHAIN_ID = window.ARCA_CONFIG?.chainId || 8453;
const BASE_RPC = window.ARCA_CONFIG?.rpcUrl || 'https://mainnet.base.org';

// ═══════════════════════════════════════
// EIP-6963: Discover all installed wallets
// ═══════════════════════════════════════
const discoveredWallets = [];

function startWalletDiscovery() {
  window.addEventListener('eip6963:announceProvider', (event) => {
    const { info, provider } = event.detail;
    // Avoid duplicates
    if (!discoveredWallets.find(w => w.info.uuid === info.uuid)) {
      discoveredWallets.push({ info, provider });
      renderWalletList();
    }
  });
  // Request providers
  window.dispatchEvent(new Event('eip6963:requestProvider'));
}

// ═══════════════════════════════════════
// Wallet Connection Methods
// ═══════════════════════════════════════

// Connect via EIP-6963 discovered wallet
async function connectEIP6963(walletProvider) {
  const accounts = await walletProvider.request({ method: 'eth_requestAccounts' });
  return { provider: walletProvider, accounts };
}

// Connect via WalletConnect (QR code)
async function connectWalletConnect() {
  if (!WC_PROJECT_ID) {
    throw new Error('WalletConnect not configured yet');
  }

  const provider = await EthereumProvider.init({
    projectId: WC_PROJECT_ID,
    chains: [BASE_CHAIN_ID],
    showQrModal: true,
    rpcMap: {
      [BASE_CHAIN_ID]: BASE_RPC,
    },
    metadata: {
      name: 'ARCA Presale',
      description: 'Community presale for $ARCA token on Base',
      url: 'https://arcabot.eth.limo',
      icons: ['https://arcabot.eth.limo/avatar.png'],
    },
  });

  await provider.connect();
  return { provider, accounts: provider.accounts };
}

// Connect via Coinbase Wallet SDK
async function connectCoinbase() {
  const sdk = new CoinbaseWalletSDK({
    appName: 'ARCA Presale',
    appLogoUrl: 'https://arcabot.eth.limo/avatar.png',
  });

  const provider = sdk.makeWeb3Provider(BASE_RPC, BASE_CHAIN_ID);
  const accounts = await provider.request({ method: 'eth_requestAccounts' });
  return { provider, accounts };
}

// Connect via legacy window.ethereum (fallback)
async function connectInjected() {
  if (!window.ethereum) throw new Error('No wallet detected');
  const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
  return { provider: window.ethereum, accounts };
}

// ═══════════════════════════════════════
// Wallet Selection Modal
// ═══════════════════════════════════════

function createModal() {
  // Remove existing modal
  document.getElementById('walletModal')?.remove();

  const modal = document.createElement('div');
  modal.id = 'walletModal';
  modal.innerHTML = `
    <div class="wm-overlay" onclick="window.closeWalletModal()"></div>
    <div class="wm-content">
      <div class="wm-header">
        <span class="wm-title">Connect Wallet</span>
        <button class="wm-close" onclick="window.closeWalletModal()">✕</button>
      </div>
      <div class="wm-subtitle">Choose how to connect</div>
      <div id="walletList" class="wm-list"></div>
      <div class="wm-divider"><span>or</span></div>
      <div class="wm-extras">
        <button class="wm-extra-btn" id="wcBtn" onclick="window.connectViaWC()">
          <span class="wm-extra-icon">📱</span>
          <span>
            <span class="wm-extra-name">WalletConnect</span>
            <span class="wm-extra-desc">Scan QR with mobile wallet</span>
          </span>
        </button>
        <button class="wm-extra-btn" id="cbBtn" onclick="window.connectViaCB()">
          <span class="wm-extra-icon">🔵</span>
          <span>
            <span class="wm-extra-name">Coinbase Wallet</span>
            <span class="wm-extra-desc">Connect via Coinbase app</span>
          </span>
        </button>
      </div>
      <div class="wm-footer">
        Don't have a wallet? <a href="https://www.coinbase.com/wallet" target="_blank">Get Coinbase Wallet</a>
      </div>
    </div>
  `;

  // Inject styles
  if (!document.getElementById('walletModalStyles')) {
    const style = document.createElement('style');
    style.id = 'walletModalStyles';
    style.textContent = `
      #walletModal { position: fixed; top: 0; left: 0; right: 0; bottom: 0; z-index: 1000; display: flex; align-items: center; justify-content: center; }
      .wm-overlay { position: absolute; inset: 0; background: rgba(0,0,0,0.7); backdrop-filter: blur(4px); }
      .wm-content { position: relative; background: #111827; border: 1px solid rgba(245,158,11,0.15); border-radius: 16px; padding: 1.5rem; width: 380px; max-width: 90vw; max-height: 80vh; overflow-y: auto; }
      .wm-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.25rem; }
      .wm-title { font-size: 1.1rem; font-weight: 700; color: #f1f5f9; }
      .wm-close { background: none; border: none; color: #64748b; font-size: 1.2rem; cursor: pointer; padding: 0.25rem; }
      .wm-close:hover { color: #f1f5f9; }
      .wm-subtitle { font-size: 0.78rem; color: #64748b; margin-bottom: 1rem; }
      .wm-list { display: grid; gap: 0.5rem; }
      .wm-wallet-btn { display: flex; align-items: center; gap: 0.75rem; width: 100%; padding: 0.75rem; background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.06); border-radius: 10px; cursor: pointer; transition: all 0.2s; color: #f1f5f9; }
      .wm-wallet-btn:hover { background: rgba(245,158,11,0.08); border-color: rgba(245,158,11,0.2); }
      .wm-wallet-icon { width: 36px; height: 36px; border-radius: 8px; object-fit: cover; }
      .wm-wallet-icon-placeholder { width: 36px; height: 36px; border-radius: 8px; background: linear-gradient(135deg, #3b82f6, #8b5cf6); display: flex; align-items: center; justify-content: center; font-size: 1rem; flex-shrink: 0; }
      .wm-wallet-name { font-size: 0.85rem; font-weight: 600; }
      .wm-wallet-tag { font-size: 0.6rem; padding: 0.1rem 0.35rem; border-radius: 4px; background: rgba(34,197,94,0.12); color: #22c55e; margin-left: 0.35rem; font-weight: 600; }
      .wm-divider { display: flex; align-items: center; gap: 0.75rem; margin: 1rem 0; }
      .wm-divider::before, .wm-divider::after { content: ''; flex: 1; height: 1px; background: rgba(255,255,255,0.06); }
      .wm-divider span { font-size: 0.7rem; color: #64748b; text-transform: uppercase; }
      .wm-extras { display: grid; gap: 0.5rem; }
      .wm-extra-btn { display: flex; align-items: center; gap: 0.75rem; width: 100%; padding: 0.75rem; background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.06); border-radius: 10px; cursor: pointer; transition: all 0.2s; color: #f1f5f9; text-align: left; }
      .wm-extra-btn:hover { background: rgba(255,255,255,0.06); border-color: rgba(255,255,255,0.12); }
      .wm-extra-btn:disabled { opacity: 0.4; cursor: not-allowed; }
      .wm-extra-icon { font-size: 1.4rem; flex-shrink: 0; width: 36px; text-align: center; }
      .wm-extra-name { font-size: 0.85rem; font-weight: 600; display: block; }
      .wm-extra-desc { font-size: 0.68rem; color: #64748b; display: block; margin-top: 0.1rem; }
      .wm-footer { text-align: center; font-size: 0.7rem; color: #64748b; margin-top: 1rem; padding-top: 0.75rem; border-top: 1px solid rgba(255,255,255,0.04); }
      .wm-footer a { color: #3b82f6; text-decoration: none; }
      .wm-footer a:hover { text-decoration: underline; }
      .wm-no-wallets { text-align: center; padding: 1rem; color: #64748b; font-size: 0.8rem; }
    `;
    document.head.appendChild(style);
  }

  document.body.appendChild(modal);
  renderWalletList();

  // Disable WC button if no project ID
  if (!WC_PROJECT_ID) {
    const wcBtn = document.getElementById('wcBtn');
    if (wcBtn) {
      wcBtn.disabled = true;
      wcBtn.querySelector('.wm-extra-desc').textContent = 'Coming soon';
    }
  }
}

function renderWalletList() {
  const list = document.getElementById('walletList');
  if (!list) return;

  if (discoveredWallets.length === 0) {
    // Fallback: check for window.ethereum
    if (window.ethereum) {
      list.innerHTML = `
        <button class="wm-wallet-btn" onclick="window.connectViaInjected()">
          <div class="wm-wallet-icon-placeholder">🦊</div>
          <span>
            <span class="wm-wallet-name">Browser Wallet<span class="wm-wallet-tag">detected</span></span>
          </span>
        </button>
      `;
    } else {
      list.innerHTML = '<div class="wm-no-wallets">No browser wallets detected. Use WalletConnect or Coinbase below.</div>';
    }
    return;
  }

  list.innerHTML = discoveredWallets.map((w, i) => `
    <button class="wm-wallet-btn" onclick="window.connectViaEIP6963(${i})">
      ${w.info.icon 
        ? `<img class="wm-wallet-icon" src="${w.info.icon}" alt="${w.info.name}">`
        : `<div class="wm-wallet-icon-placeholder">🔗</div>`
      }
      <span>
        <span class="wm-wallet-name">${w.info.name}<span class="wm-wallet-tag">installed</span></span>
      </span>
    </button>
  `).join('');
}

// ═══════════════════════════════════════
// Global API (used by HTML onclick handlers)
// ═══════════════════════════════════════

window.openWalletModal = () => createModal();
window.closeWalletModal = () => document.getElementById('walletModal')?.remove();

window.connectViaEIP6963 = async (index) => {
  try {
    const wallet = discoveredWallets[index];
    const result = await connectEIP6963(wallet.provider);
    window.closeWalletModal();
    window.onWalletConnected?.(result.provider, result.accounts[0], wallet.info.name);
  } catch (e) {
    console.error('EIP-6963 connect error:', e);
    window.onWalletError?.(e.message);
  }
};

window.connectViaWC = async () => {
  try {
    const result = await connectWalletConnect();
    window.closeWalletModal();
    window.onWalletConnected?.(result.provider, result.accounts[0], 'WalletConnect');
  } catch (e) {
    console.error('WalletConnect error:', e);
    window.onWalletError?.(e.message);
  }
};

window.connectViaCB = async () => {
  try {
    const result = await connectCoinbase();
    window.closeWalletModal();
    window.onWalletConnected?.(result.provider, result.accounts[0], 'Coinbase Wallet');
  } catch (e) {
    console.error('Coinbase error:', e);
    window.onWalletError?.(e.message);
  }
};

window.connectViaInjected = async () => {
  try {
    const result = await connectInjected();
    window.closeWalletModal();
    window.onWalletConnected?.(result.provider, result.accounts[0], 'Browser Wallet');
  } catch (e) {
    console.error('Injected error:', e);
    window.onWalletError?.(e.message);
  }
};

// Start discovering wallets immediately
startWalletDiscovery();

console.log('[ARCA] Wallet connector loaded');
