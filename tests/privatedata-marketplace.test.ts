import { describe, it, expect } from 'vitest';
import { Cl } from '@stacks/transactions';

const accounts = simnet.getAccounts();
const address1 = accounts.get('wallet_1')!;
const address2 = accounts.get('wallet_2')!;

describe('PrivateData Marketplace - Minimal Test', () => {
  it('should certify data privacy successfully', () => {
    // Create a simple data hash
    const dataHash = new Uint8Array(32).fill(1);
    
    // Call the privacy certification function
    const response = simnet.callPublicFn(
      'data-privacy',
      'certify-data-privacy',
      [
        Cl.buffer(dataHash),
        Cl.uint(1), // PRIVACY-BASIC
        Cl.stringAscii('k-anonymity')
      ],
      address1
    );
    
    // Use the built-in matchers from Clarinet SDK
    expect(response.result).toBeOk(Cl.bool(true));
    
    // Verify the certification was stored
    const getCert = simnet.callReadOnlyFn(
      'data-privacy',
      'get-privacy-certification',
      [Cl.buffer(dataHash)],
      address1
    );
    
    // Check that we get Some value back (certification exists)
    // TODO: Consider more specific validation of certification data structure
    expect(getCert.result).not.toBeNone();
  });

  it('should create a marketplace listing after privacy certification', () => {
    // Use a different hash for this test
    const dataHash = new Uint8Array(32).fill(2);
    
    // First certify the privacy
    simnet.callPublicFn(
      'data-privacy',
      'certify-data-privacy',
      [
        Cl.buffer(dataHash),
        Cl.uint(2), // PRIVACY-ENHANCED
        Cl.stringAscii('differential-privacy')
      ],
      address1
    );
    
    // Now create the marketplace listing
    const listingResponse = simnet.callPublicFn(
      'privatedata-marketplace',
      'create-listing',
      [
        Cl.stringAscii('test-data'),
        Cl.stringAscii('Test dataset'),
        Cl.uint(1000000), // 1 STX
        Cl.stringAscii('enhanced'),
        Cl.buffer(dataHash),
        Cl.stringAscii('https://example.com'),
        Cl.uint(1000) // duration
      ],
      address1
    );
    
    // Should return the listing ID (1)
    expect(listingResponse.result).toBeOk(Cl.uint(1));
  });

  it('should purchase data successfully', () => {
    // Purchase the listing created in the previous test
    const purchaseResponse = simnet.callPublicFn(
      'privatedata-marketplace',
      'purchase-data',
      [Cl.uint(1)], // listing ID
      address2
    );
    
    // Should return the purchase ID (1)
    expect(purchaseResponse.result).toBeOk(Cl.uint(1));
    
    // Verify access was granted
    const hasAccess = simnet.callReadOnlyFn(
      'privatedata-marketplace',
      'has-data-access',
      [Cl.uint(1), Cl.principal(address2)],
      address2
    );
    
    expect(hasAccess.result).toBeBool(true);
  });
});