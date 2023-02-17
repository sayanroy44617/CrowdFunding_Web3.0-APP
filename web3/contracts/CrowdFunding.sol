// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target; //target amount to be collected
        uint256 deadline;
        uint256 amountCollected; // collected amount till date
        string image; //url of the image
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public Campaigns;
    // this mapping is done to map an int with the campaigns so that we
    //can use campaigns as campaigns[0] and so on

    uint256 public numberOfCampaigns = 0;

    //this function is to create a new campaigns and as we can access it from the frontned
    //thats why it is public and it returns an unt256 which is the id of the campaign
    function creatCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    ) public returns (uint256) {
        Campaign storage campaign = Campaigns[numberOfCampaigns];

        //this is a check to satisfy if everything is fine while creating a campaign
        //require(condition, message);
        require(
            campaign.deadline < block.timestamp,
            " Deadline cannot be in the past "
        );

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    //payable is a specified keyword that mean taht some transaction is going
    //to happen in this function
    function donateToCampaign(uint256 _id) public payable {
        Campaign storage campaign = Campaigns[_id];
        uint256 amount = msg.value;
        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        // righthand size ezpression is  to start the transaction
        //payable(whom to sent).call{value : amount to sent}.("")
        //this returns a bool and a bytes value containing any return data from the function being called.
        (bool sent, ) = payable(campaign.owner).call{
            value: amount
        }("");

        if (sent == true) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }

    function getDonators(uint256 _id)
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        return (Campaigns[_id].donators, Campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory campaignlist = new Campaign[](numberOfCampaigns);
        for (uint256 index = 0; index < numberOfCampaigns; index++) {
            Campaign storage item = Campaigns[index];
            campaignlist[index] = item;
        }
        return campaignlist;
    }
}
