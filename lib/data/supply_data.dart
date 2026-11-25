class SupplyInfo {
  final String name;
  final double circulating;
  final double? max;

  const SupplyInfo(this.name, this.circulating, [this.max]);
}

// approximate supply figures, Binance does not publish market cap or supply
const Map<String, SupplyInfo> supplyData = {
  'BTC': SupplyInfo('Bitcoin', 19900000, 21000000),
  'ETH': SupplyInfo('Ethereum', 120700000),
  'BNB': SupplyInfo('BNB', 145900000, 200000000),
  'SOL': SupplyInfo('Solana', 470000000),
  'XRP': SupplyInfo('XRP', 58000000000, 100000000000),
  'ADA': SupplyInfo('Cardano', 36000000000, 45000000000),
  'DOGE': SupplyInfo('Dogecoin', 150000000000),
  'TRX': SupplyInfo('TRON', 94000000000),
  'AVAX': SupplyInfo('Avalanche', 410000000, 720000000),
  'DOT': SupplyInfo('Polkadot', 1500000000),
  'LINK': SupplyInfo('Chainlink', 650000000, 1000000000),
  'POL': SupplyInfo('Polygon', 10600000000),
  'LTC': SupplyInfo('Litecoin', 76000000, 84000000),
  'BCH': SupplyInfo('Bitcoin Cash', 19900000, 21000000),
  'SHIB': SupplyInfo('Shiba Inu', 589000000000000),
  'UNI': SupplyInfo('Uniswap', 600000000, 1000000000),
  'ATOM': SupplyInfo('Cosmos', 390000000),
  'XLM': SupplyInfo('Stellar', 31000000000, 50000000000),
  'ETC': SupplyInfo('Ethereum Classic', 152000000, 210700000),
  'NEAR': SupplyInfo('NEAR Protocol', 1200000000),
  'APT': SupplyInfo('Aptos', 600000000),
  'FIL': SupplyInfo('Filecoin', 600000000, 2000000000),
  'ARB': SupplyInfo('Arbitrum', 4000000000, 10000000000),
  'OP': SupplyInfo('Optimism', 1600000000, 4294967296),
  'HBAR': SupplyInfo('Hedera', 42000000000, 50000000000),
  'ICP': SupplyInfo('Internet Computer', 480000000),
  'SUI': SupplyInfo('Sui', 3300000000, 10000000000),
  'TON': SupplyInfo('Toncoin', 2500000000),
  'PEPE': SupplyInfo('Pepe', 420000000000000, 420690000000000),
  'AAVE': SupplyInfo('Aave', 15000000, 16000000),
  'INJ': SupplyInfo('Injective', 99000000, 100000000),
  'RUNE': SupplyInfo('THORChain', 350000000, 500000000),
  'ALGO': SupplyInfo('Algorand', 8500000000, 10000000000),
  'VET': SupplyInfo('VeChain', 80000000000, 86700000000),
};

const Set<String> stableBases = {
  'USDC', 'FDUSD', 'TUSD', 'USDP', 'DAI', 'BUSD', 'EUR', 'AEUR', 'USD1',
  'XUSD', 'PAXG', 'EURI', 'USDE', 'BFUSD',
};

const List<String> leveragedSuffixes = ['UP', 'DOWN', 'BULL', 'BEAR'];
