import { useState } from "react";
import "./App.css";

const App = () => {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    message: "",
  });
  const [submitted, setSubmitted] = useState(false);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    // Replace YOUR_FORM_ID with your Formspree form ID
    const response = await fetch("https://formspree.io/f/YOUR_FORM_ID", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(formData),
    });
    if (response.ok) {
      setSubmitted(true);
    }
  };

  return (
    <div className="app">
      {/* Hero Section */}
      <section className="hero">
        <nav className="nav">
          <div className="logo">CCG</div>
          <a href="#contact" className="nav-link">Contact</a>
        </nav>

        <div className="hero-content">
          <h1 className="hero-title">CCG</h1>
          <div className="hero-line"></div>
          <p className="hero-subtitle">Cusco Consulting Group</p>
          <p className="hero-tagline">Strategic counsel for exceptional circumstances</p>
        </div>

        <div className="scroll-indicator">
          <span></span>
        </div>
      </section>

      {/* Philosophy Section */}
      <section className="philosophy">
        <div className="container">
          <h2 className="section-title">Approach</h2>
          <div className="philosophy-content">
            <p className="philosophy-lead">
              We operate at the intersection of complexity and clarity.
            </p>
            <p className="philosophy-text">
              For organizations navigating inflection points—structural transformation,
              strategic realignment, or operational refinement—we provide the perspective
              and precision that circumstances demand.
            </p>
            <p className="philosophy-text">
              Our engagements are selective. Our methods are discreet.
              Our commitment is absolute.
            </p>
          </div>

          <div className="domains">
            <div className="domain">
              <span className="domain-marker"></span>
              <span className="domain-text">Strategy & Structure</span>
            </div>
            <div className="domain">
              <span className="domain-marker"></span>
              <span className="domain-text">Operations & Performance</span>
            </div>
            <div className="domain">
              <span className="domain-marker"></span>
              <span className="domain-text">Capital & Investment</span>
            </div>
          </div>
        </div>
      </section>

      {/* Contact Section */}
      <section className="contact" id="contact">
        <div className="container">
          <h2 className="section-title">Inquiries</h2>

          {!submitted ? (
            <form className="contact-form" onSubmit={handleSubmit}>
              <div className="form-group">
                <input
                  type="text"
                  name="name"
                  placeholder="Name"
                  value={formData.name}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className="form-group">
                <input
                  type="email"
                  name="email"
                  placeholder="Email"
                  value={formData.email}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className="form-group">
                <textarea
                  name="message"
                  placeholder="How may we be of service?"
                  rows="4"
                  value={formData.message}
                  onChange={handleChange}
                  required
                ></textarea>
              </div>
              <button type="submit" className="submit-btn">
                <span>Submit Inquiry</span>
                <span className="btn-line"></span>
              </button>
            </form>
          ) : (
            <div className="form-success">
              <p>Your inquiry has been received.</p>
              <p className="success-sub">We will respond at our earliest opportunity.</p>
            </div>
          )}
        </div>
      </section>

      {/* Footer */}
      <footer className="footer">
        <div className="container">
          <div className="footer-content">
            <div className="footer-logo">CCG</div>
            <p className="footer-text">Cusco Consulting Group</p>
            <p className="footer-copyright">&copy; {new Date().getFullYear()}</p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default App;
