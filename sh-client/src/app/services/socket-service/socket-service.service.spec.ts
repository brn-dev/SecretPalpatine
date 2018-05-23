import { TestBed, inject } from '@angular/core/testing';

import { SocketServiceService } from './socket-service.service';

describe('SocketServiceService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [SocketServiceService]
    });
  });

  it('should be created', inject([SocketServiceService], (service: SocketServiceService) => {
    expect(service).toBeTruthy();
  }));
});
