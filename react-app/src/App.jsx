import logo from './logo.svg';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="React logo" />
        <h1>React on AWS</h1>
        <p>
          Served from a private S3 bucket through CloudFront (Origin Access Control),
          provisioned with Terraform.
        </p>
      </header>
    </div>
  );
}

export default App;
