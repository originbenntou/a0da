import React, { useEffect, useState } from 'react';
import { Row, Col } from 'reactstrap';
import CustomImage from './CustomImage';
import Loading from './Loading';

const dummyImage = 'https://d31r3kj2zpg47q.cloudfront.net/dummy.png';

function Demo() {
  const [token, setToken] = useState(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const fetchToken = async () => {
      try {
        const response = await fetch('http://localhost:3000/api/token');
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        const data = await response.json();
        setToken(data.access_token);
      } catch (error) {
        console.error('Error fetching the token:', error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchToken();
  }, []);
  
  if (loading) {
    return <Loading />;
  }
  
  return (
    <>
      <div className="next-steps" data-testid="content">
        <Row className="d-flex justify-content-between" data-testid="content-items">
          <Col md={2} className="mb-4">
            <CustomImage src={dummyImage} width={128} height={128} alt={"dummy_download"} token={token} />
          </Col>
        </Row>
      </div>
    </>
  );
}

export default Demo;