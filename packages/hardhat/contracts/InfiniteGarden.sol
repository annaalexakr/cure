// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import { ERC721Tradable } from "./base/ERC721Tradable.sol";
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { SafeERC20 } from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import { IWETH } from './interfaces/IWETH.sol';
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

//           ,,_
//        zd$$??=
//      z$$P? F:`c,                _
//     d$$, `c'we&&i           ,=caRe
//    $$$$garden,?888i       ,=P"2?us"
//     $" " ?$$$,?888.    ,-''`>, bee
//      $'joy,?$$,?888   ,h' "I$'J$e
//       ... `?$$$,"88,`$$h  88love'd$"
//     d$PP""?-,"?$$,?8h`$$,,88'$Q42"
//     ?,,_`=4c,?=,"?ye$s`?E2$'? '
//        `""?==""=-"" `""-`'_,,,,
//            .eco?quality,-,"=?
//                      """=='?"

contract InfiniteGarden is ERC721Tradable {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    event GoodCreated(address indexed signer, uint256 amount, uint256 indexed tokenId, string uri);
    event Upvote(address voter, uint256 amount, uint256 id);
    event Downvote(address voter, uint256 amount, uint256 id);
    event GoodHarvested(uint256 id, uint256 grantAmount);
    event GoodPruned(uint256 id);

    error NotAuthorized();

    // An address responsible for harvesting and pruning - should be a DAO etc.
    address public gardener;

    // The address of the WETH contract
    address public weth;

    struct Voter {
        address voter;
        uint256 amount;
    }

    mapping(uint256 => Voter[]) public supporters;
    mapping(uint256 => Voter[]) public critics;

    mapping (uint256 => uint256) public rank;

    modifier onlyGardener() {
        if (msg.sender != gardener) {
            revert NotAuthorized();
        }
        _;
    }

    constructor(
        address _proxyRegistryAddress,
        address _creator,
        address _weth
    ) ERC721Tradable('Infinite Garden', 'GARD', _proxyRegistryAddress) {
        gardener = _creator;
        weth = _weth;
    }

    /**
     * @notice Link to contract metadata
    */
    function contractURI() 
        external 
        pure 
        returns (string memory) 
    {
        return "";
    }

    /**
     * @dev       Receives donation and mints new NFT for donor
     * @param uri a string that sets the initial uri for this NFT
     */
    function createGood(string memory uri) 
        external 
        payable 
    {
        require(msg.value >= 0.01 ether, "Minimum cost is 0.01 ETH");

        uint256 newTokenId = _tokenIdCounter.current();
        _safeMint(gardener, msg.sender, newTokenId);
        _setTokenURI(newTokenId, uri);
        _tokenIdCounter.increment();
        emit GoodCreated(msg.sender, msg.value, newTokenId, uri);

        _safeTransferETHWithFallback(address(this), msg.value);
    }

   /**
     * @notice   allows anyone to vote on an NFT by sending ETH to the contract
     * @param id the id of the token being voted on
     */
    function upvote(uint256 id) 
        external 
        payable
    {
        require(msg.value >= 0, "You have to spend some ETH to vote");

        uint256 index = supporters[id].length;

        supporters[id][index] = Voter(
            msg.sender,
            msg.value
        );

        rank[id] += msg.value;

        emit Upvote(msg.sender, msg.value, id);
        _safeTransferETHWithFallback(address(this), msg.value);
    }

    /**
     * @notice   allows anyone to vote on an NFT by sending ETH to the contract
     * @param id the id of the token being voted on
     */
    function downvote(uint256 id) 
        external 
        payable
    {
        require(msg.value >= 0, "You have to spend some ETH to vote");

        uint256 index = supporters[id].length;

        critics[id][index] = Voter(
            msg.sender,
            msg.value
        );

        rank[id] -= msg.value;

        emit Downvote(msg.sender, msg.value, id);
        _safeTransferETHWithFallback(address(this), msg.value);
    }

    /**
     * @notice   allows the gardener to allocate a grant to this NFT holder transparently. 
     *           Those who upvoted share in rewards on a pro-rata basis.
     * @param id the id of the token being sent a grant
     */
    function harvest(uint256 id) 
        external 
        payable
        onlyGardener
    {
        uint256 rewarded = supporters[id].length;
        uint256 portion = msg.value / 10;
        uint256 reward = rank[id] + portion / rewarded;
        // TODO: send this reward to each voter

        address steward = ERC721Tradable.ownerOf(id);

        _safeTransferETHWithFallback(address(this), msg.value);
    }

    /**
     * @notice   allows the gardener to refuse this grant. 
     *           Those who downvoted get pro-rata portion of whatever was spent to mint + vote
     * @param id the id of the token being voted on
     */
    function prune(uint256 id) 
        external
        payable
        onlyGardener 
    {
        uint256 rewarded = critics[id].length;
        // TODO: ideally we'd figure out how much each critic voted, return that to them and add some reward for 
        // keeping the garden functional and clean.
        uint reward = rank[id] / rewarded;
        ERC721Tradable._burn(id);
    }

    /**
     * @notice       Transfer ETH. If the ETH transfer fails, wrap the ETH and try send it as WETH.
     * @param amount the total amount
     */
    function _safeTransferETHWithFallback(address to, uint256 amount) internal {
        if (!_safeTransferETH(to, amount)) {
            IWETH(weth).deposit{ value: amount }();
            IERC20(weth).safeTransfer(to, amount);
        }
    }

    /**
     * @notice Transfer ETH and return the success status.
     */
    function _safeTransferETH(address to, uint256 amount) internal returns (bool) {
        (bool success, ) = to.call{value: amount, gas: 30_000 }(new bytes(0));
        return success;
    }

}