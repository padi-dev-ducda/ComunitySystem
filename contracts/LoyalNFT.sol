// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
contract LoyalNFT is ERC721, ReentrancyGuard, Ownable  {
	using Strings for uint256;
	using Counters for Counters.Counter;

	Counters.Counter private _tokenId;

	string private baseURI;
	string private baseExt = ".json";

	// Total supply
	// uint256 public constant MAX_SUPPLY = 41;

	// Public mint constants
	bool public saleActive = false;
	// uint256 private constant MAX_PER_WALLET = 3; // 2/wallet (uses < to save gas)
	uint256 private price = 1000;

	bool private _locked = false; // for re-entrancy guard
    address tokenERC20; 
	// Initializes the contract by setting a `name` and a `symbol`
	constructor(string memory _initBaseURI, address _tokenERC20) ERC721("LoyalNFT", "LNFT") {
        tokenERC20 = _tokenERC20;
		_tokenId.increment();
		setBaseURI(_initBaseURI);
        
	}

	// Mint an NFT
	function buynft() external payable nonReentrant {
		require(saleActive, "Sale is closed at the moment.");
        address _to = msg.sender;
        require(IERC20(tokenERC20).transferFrom(msg.sender,address(this),price),"Not enough ERC20 tokens transferred");
        _mint(_to);
        if (_tokenId.current() % 2 == 0 ) {
            price = price + price*20/100; 
        }
	}

	// Itrative mint handler
	function _mint(address _to) private {
		/**
		 * To save gas, since we know _quantity won't overflow
		 * Checks are performed in caller functions / methods
		 */
		unchecked {
		    _safeMint(_to, _tokenId.current());
            _tokenId.increment();
		}
	}

	// Toggle sale state
	function toggleSaleState() public onlyOwner {
		saleActive = !saleActive;
	}

	// Get total supply
	function totalSupply() public view returns (uint256) {
		return _tokenId.current() - 1;
	}

	// Base URI
	function _baseURI() internal view virtual override returns (string memory) {
		return baseURI;
	}

	// Set base URI
	function setBaseURI(string memory _newBaseURI) public {
		baseURI = _newBaseURI;
	}

	// Get metadata URI
	function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
		require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token.");

		string memory currentBaseURI = _baseURI();
		return
			bytes(currentBaseURI).length > 0
				? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExt))
				: "";
	}

	// Withdraw balance
	function withdraw() external onlyOwner {
		// Transfer the remaining balance to the owner
		// Do not remove this line, else you won't be able to withdraw the funds
		(bool sent, ) = payable(owner()).call{ value: address(this).balance }("");
		require(sent, "Failed to withdraw Ether.");
	}

	// Receive any funds sent to the contract
	receive() external payable {}
    function currentPrice() public view returns (uint256) {
        return price;
    }
}